# [WIP] CNF Conformance Tooling Research Notes

# Tooling options for Privileged Pods test.

## OPA

OPA is a policy tool and the test concept would be to apply a policy that blocks / rejects the deployments of Pods with privlidged mode, and attempt to install the CNF we're testing to see if it can be installed. If the Pods requires privlidged mode OPA will reject the deployment and the test will return an exit code. However, this test case is not ideal because it would require us to re-deploy the CNF just to 'check' if the Pod is running in Privileged mode. 

A possible work around for this would be to apply the OPA policies before the CNF is deployed and then utilize OPA's [Audit](https://github.com/open-policy-agent/gatekeeper#audit) serivce which preforms periodic evaluations of K8s resources against enforced policies to detect pre-existing violations. Audit results for pre-existing pods that are violating constraints are available under the 'status' field of the failed constraint.
```
status:
  auditTimestamp: "2019-05-11T01:46:13Z"
  enforced: true
  violations:
  - enforcementAction: deny
    kind: Namespace
    message: 'you must provide labels: {"gatekeeper"}'
    name: default
  - enforcementAction: deny
```

#### Pseudo code for an OPA policy / constraint denies Privileged Pods:   

Install Gatekeeper:
```
helm repo add mesosphere-staging https://mesosphere.github.io/charts/staging
helm install mesosphere-staging/gatekeeper --name gatekeeper
```

Constraint Template:
```
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8spspprivilegedcontainer
spec:
  crd:
    spec:
      names:
        kind: K8sPSPPrivilegedContainer
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8spspprivileged

        violation[{"msg": msg, "details": {}}] {
            c := input_containers[_]
            c.securityContext.privileged
            msg := sprintf("Privileged container is not allowed: %v, securityContext: %v", [c.name, c.securityContext])
        }

        input_containers[c] {
            c := input.review.object.spec.containers[_]
        }

        input_containers[c] {
            c := input.review.object.spec.initContainers[_]
        }
```

Constraint Enforcement:
```
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sPSPPrivilegedContainer
metadata:
  name: psp-privileged-container
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

## Falco
Falco is a system security audit tool that provides insight to the events happening on the system at the kernal level. The concept of the test would be to create a Falco rule that would watch the host system for any containers that are spawned with Privlidged access. When we run the Privileged mode test we would check the logs of the deployed CNF and search the logs for any Falco 'WARNING' events that would indicate the container is running in Privileged mode and if found the test would return an error code.

#### Pseudo code for a Falco rule which checks for Privileged Pods:

Install Flaco:
```
helm install --name falco stable/falco
```

Audit Rule:
```
- rule: Container running with Privileged mode
  desc: Any container running with privileged mode.
  condition: container.privileged=true
  output: Container running in privileged mode (user=%user.name command=%proc.cmdline %container.info)
  priority: WARNING
  tags: [container, cis]
```
