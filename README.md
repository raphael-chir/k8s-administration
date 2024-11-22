[![Generic badge](https://img.shields.io/badge/Version-1.0-<COLOR>.svg)](https://shields.io/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)
![Maintainer](https://img.shields.io/badge/maintainer-raphael.chir@gmail.com-blue)
# K8S Administration

## Contents
- [K8S installations](01-k8s-installation/README.md)
- [kubectl](02-kubectl/README.md)


## Releases history
| **Version** | **Release Date**   | **Major Breaking Change**                        | **Impact on Installation**                              |
|-------------|---------------------|--------------------------------------------------|--------------------------------------------------------|
| 1.31        | August 20, 2024    | TLSv1.3 mandatory.                              | Verify compatibility of existing TLS clients.          |
| 1.30        | April 15, 2024     | CRD version V1 mandatory.                       | Convert all CRDs still in V1beta1.                     |
| 1.29        | December 11, 2023  | Default Feature Gates adjustments.              | Review automatic feature activations.                  |
| 1.28        | August 15, 2023    | Obsolete APIs removed.                          | Update manifests and CRDs.                             |
| 1.27        | April 11, 2023     | Dynamic KMS v2 required.                        | Review encryption-at-rest configuration.               |
| 1.26        | December 9, 2022   | JSONpath deprecated.                            | Update kubectl scripts using JSONpath.                 |
| 1.25        | August 23, 2022    | Obsolete alpha APIs removed.                    | Migrate or replace deprecated alpha features.          |
| 1.24        | May 3, 2022        | Docker-shim removed.                            | Replace with CRI-compatible runtimes.                  |
| 1.23        | December 7, 2021   | PodSecurityPolicy deprecated.                   | Implement alternatives like OPA/Gatekeeper.            |
| 1.22        | August 4, 2021     | API v1beta1 removed.                            | Mandatory migration of CRDs to `v1`.                   |
| 1.21        | April 8, 2021      | Seccomp default enabled.                        | Pods must include proper Seccomp configurations.        |
| 1.20        | December 8, 2020   | Docker-shim deprecated.                         | Migration to other runtimes (e.g., containerd).         |
| 1.19        | August 26, 2020    | Limited Beta API support.                       | Mandatory API updates to `v1`.                         |
| 1.18        | March 25, 2020     | IngressClass introduced.                        | Existing ingress must define an `IngressClass`.         |
| 1.17        | December 9, 2019   | Beta Volume Snapshot introduced.                | Adjustments needed for dynamic volume management.       |
| 1.16        | September 18, 2019 | Deprecated APIs removed.                        | Update manifests using obsolete APIs.                  |
| 1.15        | June 19, 2019      | Extensions moved to AppsV1.                     | Mandatory updates for deprecated API versions.          |
| 1.14        | March 25, 2019     | Windows support introduced.                     | Adjustments needed for Windows nodes.                  |
| 1.13        | December 3, 2018   | CRIContainerd default enabled.                  | Verify Docker/containerd runtime compatibility.         |
| 1.12        | September 27, 2018 | Dynamic Kubelet Config activated.               | Node configuration requires adaptation for automation.  |
| 1.11        | June 27, 2018      | CoreDNS replaces kube-dns.                      | Manual migration to CoreDNS may be needed.              |
| 1.10        | March 26, 2018     | Secure kubelet communication enabled.           | Certificates and kubelet settings must be verified.     |
| 1.9         | December 15, 2017  | Stable AppsV1 API.                              | Update manifests to `apps/v1`.                         |
| 1.8         | September 28, 2017 | Out-of-tree volume plugins.                     | Reconfiguration may be needed for specific plugins.     |
| 1.7         | June 29, 2017      | NetworkPolicy GA.                               | Pods must comply with new network policies.             |
| 1.6         | March 28, 2017     | Default RBAC activated.                         | RBAC rules must be updated to manage API access.        |
| 1.5         | December 8, 2016   | PodSecurityPolicy introduced.                   | Security policies must be explicitly defined.           |
| 1.4         | September 26, 2016 | Preliminary RBAC introduced.                    | Manual configuration required to activate RBAC.         |
| 1.3         | July 5, 2016       | StatefulSets introduced.                        | Migration required for StatefulSets use.               |
| 1.2         | March 15, 2016     | Custom API extensions introduced.               | CRD configuration needed for new APIs.                 |
| 1.1         | November 9, 2015   | Added ingress.                                  | Plugins for ingress require updates.                   |
| 1.0         | July 21, 2015      | Initial stable release.                         | No impact, first version.                              |

