# CNF Conformance
| Master |
|---|
|[![Build Status](https://www.travis-ci.org/cncf/cnf-conformance.svg?branch=master)](https://www.travis-ci.org/cncf/cnf-conformance)|

The CNF Conformance program enables interoperability of Cloud native Network Functions (CNFs) from multiple vendors running on top of Kubernetes supplied by different vendors. The goal is to provide an open source test suite to demonstrate conformance and implementation of best practices for both open and closed source Cloud native Network Functions. 

The CNF Conformance Test Suite will inspect CNFs for the following characteristics: 
- **Compatibility** - CNFs should work with any Certified Kubernetes product and any CNI-compatible network that meet their functionality requirements.
- **Statelessness** - The CNF's state should be stored in a custom resource definition or a separate database (e.g. etcd) rather than requiring local storage. The CNF should also be resilient to node failure.
- **Security** - CNF containers should be isolated from one another and the host.
- **Microservice** - The CNF should be developed and delivered as a microservice.
- **Scalability** - CNFs should support horizontal scaling (across multiple machines) and vertical scaling (between sizes of machines).
- **Configuration and Lifecycle** - The CNF's configuration and lifecycle should be managed in a declarative manner, using ConfigMaps, Operators, or other declarative interfaces.  
- **Observability** - CNFs should externalize their internal states in a way that supports metrics, tracing, and logging.
- **Installable and Upgradeable** - CNFs should use standard, in-band deployment tools such as Helm (version 3) charts.
- **Hardware Resources and Scheduling** - The CNF container should access all hardware and schedule to specific worker nodes by using a device plugin.
- **Resilience** - CNFs should be resilient to failures inevitable in cloud environments. CNF Resilience should be tested to ensure CNFs are designed to deal with non-carrier-grade shared cloud HW/SW platform.

See the [Conformance Test Categories Documentation](https://github.com/cncf/cnf-conformance/blob/master/TEST-CATEGORIES.md) for a complete overview of the tests.

## Contributing

Welcome! We gladly accept contributions on new conformance tests, example CNFs, updates to documentation, enhancements, bug reports and more.
- [Contributing guide](https://github.com/cncf/cnf-conformance/blob/master/CONTRIBUTING.md)
- [Good first issues](https://github.com/cncf/cnf-conformance/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)

## Communication and community meetings

- Join the conversation on [CNCF's Slack](https://slack.cncf.io/) channels
    - [#cnf-conformance](https://cloud-native.slack.com/archives/CV69TQW7Q)  
    - [#cnf-conformance-dev](https://cloud-native.slack.com/archives/C014TNCEX8R)
    
- Join the monthly [Telecom User Group meetings](https://github.com/cncf/telecom-user-group#meeting-time) 
    - Meetings on the 1st Mondays of the month 
    - Meeting minutes are [here](https://docs.google.com/document/d/1yhtI7aiwpdAiRBKyUX6mOJDHAbjOog2mI4Ur2k27D7s/edit) 
    
- Join the weekly developer meetings 
    - Meetings every Thursday at 14:15 - 15:00 UTC
    - Meeting minutes are [here](https://docs.google.com/document/d/1IbrgjqIkOCvrrSG0DRE6X62UUZpBq-818Mn8q0nkkd0/edit)

## Implementation overview

The CNF Conformance Test Suite leverages upstream tools such as [OPA Gatekeeper](https://github.com/open-policy-agent/gatekeeper), [Helm linter](https://github.com/helm/chart-testing), and [Promtool](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/) for testing CNFs. The upstream tool installation, configuration and versioning has been made repeatable.

The test framework and tests (using the upstream tools) are written in the human readable, compiled language, [Crystal](https://crystal-lang.org/). Common capabilities like dependencies between tests and categories are supported.

Setup of vanilla upstream K8s on [Packet](https://www.packet.com/) is done with the [CNF Testbed](https://github.com/cncf/cnf-testbed/) platform tool chain, which includes [k8s-infra](https://github.com/crosscloudci/k8s-infra), [Kubespray](https://kubespray.io/). To add support for other providers, please submit a [Pull Request](https://github.com/cncf/cnf-testbed/pulls) to the [CNF Testbed](https://github.com/cncf/cnf-testbed/) repo.


## Installation

Binary downloads of the CNF Conformance client can be found on the [Releases](https://github.com/cncf/cnf-conformance/releases) page.

Unpack the CNF Conformance binary and add it to your PATH and you are good to go!

*or*


Use the curl command to download, install, and export the path simultaneously:
```
source <(curl https://raw.githubusercontent.com/cncf/cnf-conformance/master/curl_install.sh)
```
*or*

Use the curl command to download and install, but you will have to export the PATH:
```
curl https://raw.githubusercontent.com/cncf/cnf-conformance/master/curl_install.sh | bash

```

To rapidly get CNF Conformance up and running, start with the Installation Guide.

See the [installation guide](https://github.com/cncf/cnf-conformance/blob/master/INSTALL.md) for more details on installing and running the CNF Conformance Test Suite. 

## Usage

Check [usage documentation](https://github.com/cncf/cnf-conformance/blob/master/USAGE.md) for more info about invoking commands and logging


## License terms

CNF Conformance is available under the [Apache 2 license](https://github.com/cncf/cnf-conformance/blob/master/LICENSE).

