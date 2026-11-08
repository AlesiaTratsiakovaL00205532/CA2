# CA2: Using Terraform and Sentinel to support Irish digital sovereignity

This is a policy-as-code framework for the example organisation ATUL0012345. Terraform defines a private AWS workload and five Sentinel policies to check residency, infrastructure security and IaC dependency declarations before deployment.

Repository: <https://github.com/AlesiaTratsiakovaL00205532/CA2>

**Testing exceptions:**

- Ireland-only production residency would require `eu-west-1`. The AWS Academy/Vocareum sandbox demonstration only allows to use `us-east-1`. So, even though the plan assumes restricting residency to `eu-west-1`, testing was done in `us-east-1`.
- The final combined HCP run uses advisory policies because Terraform HCP allows to create only one hard-mandatory policy. The repository specifies "hard-mandatory" for all policies; but the combined test was done in advisory mode for demonstration purposes.

## Project structure

```text
CA2\
  README.md
  TECHNICAL-REPORT.md
  TECHNICAL-REPORT.pdf
  terraform\
    main.tf
    variables.tf
    outputs.tf
    versions.tf
    .terraform.lock.hcl
    tfplan
    tests\compliant-example.tftest.hcl
  policies\
    sentinel.hcl
    approved-regions.sentinel
    storage-residency.sentinel
    replication-residency.sentinel
    infrastructure-security.sentinel
    supply-chain-security.sentinel
    mocks\
    test\
  evidence\
```

`terraform\tfplan` is a human-readable summary of tfplan. Raw plan was not submitted to avoid exposing sensitive variables used for authentication.

## Design and policy coverage

| Policy | Implemented checks | Important boundary |
|---|---|---|
| Approved regions - policies/approved-regions.sentinel | At least one AWS provider; approved provider regions, including aliases, and explicit resource-region overrides | Supported expressions are literal regions or root `var.region`; this is not a jurisdiction or global-service guarantee |
| Storage residency - policies/storage-residency.sentinel | Supported S3, EBS, EC2-attached storage and snapshot locations; configured regions/AZs and available planned location fields | At least one supported storage resource is required; other storage services and runtime transfers are outside scope |
| Replication residency - policies/replication-residency.sentinel | Same-approved-region S3 replication destinations and EBS snapshot-copy source/destination regions; legacy inline S3 replication rejected | Restricts copies when configured; does not require replication or prove a backup strategy exists |
| Infrastructure security - policies/infrastructure-security.sentinel | `t2.micro`/`t3.micro`, encrypted EBS, IMDSv2, managed security-group references and private network controls | Evaluates supported managed resources in the plan, not every pre-existing network path |
| Supply-chain security - policies/supply-chain-security.sentinel | Approved provider sources and exact approved versions; allowlisted module source with an exact stable version | Checks visible configuration declarations, not package contents or complete cryptographic provenance |

### Infrastructure choices

The example creates a VPC, a subnet, a security group and an Ubuntu EC2 instance. It requests no public IPv4 or IPv6 addresses, uses encrypted root EBS and requires `http_tokens = "required"` for IMDSv2. The security group has no ingress or egress.

Blocking world-open ingress on any port, public subnet defaults, public load balancers and elastic IP exposure is stricter than the assignment's unrestricted-SSH requirement. This is a private-workload demonstration, not a fully operational application: approved administration, outbound connectivity and application access would need separate design. Unsupported instance interface/launch-template configurations and unresolved required security values are rejected by the relevant checks.

The AMI is selected from Canonical's owner account using the latest matching Ubuntu image. Its exact image is not pinned in configuration, so later plans may differ; image provenance and patch lifecycle remain additional supply-chain considerations.

### Dependency integrity and provenance

Approved provider declarations are:

| Source | Exact approved version |
|---|---|
| `registry.terraform.io/hashicorp/aws` | `6.72.0` |
| `registry.terraform.io/hashicorp/random` | `3.0.1` |

Terraform uses exact `= version` constraints and a lock file terraform/.terraform.lock.hcl. Terraform generated provider checksums for Windows AMD64 and Linux AMD64 from HashiCorp-signed packages. Terraform performs checksum verification during installation; Sentinel does not independently verify package hashes. Exact pins improve reproducibility but must be reviewed and updated when fixes become available.

The module source allowlist contains `terraform-aws-modules/vpc/aws`. The policy requires an exact stable three-component version, optionally prefixed with `=`; ranges and missing versions fail. Version `6.0.1` is used in synthetic tests, not enforced as the only approved module version.

Registry metadata for that version points to `terraform-aws-modules/terraform-aws-vpc`, tag `v6.0.1`, but is not marked Registry verified. Terraform's lock file locks provider selections and checksums, not module contents.

### Effectiveness, limitations and maintenance

Policy-as-Code makes requirements repeatable, version-controlled and testable before deployment. However, region-based residency checks do not establish full digital sovereignty: they cannot determine provider jurisdiction, prevent foreign legal demands, control administrator access or encryption-key ownership, or monitor runtime data movement. These require legal, contractual and operational controls alongside Sentinel. Plan-time checks also do not continuously monitor existing resources or changes made outside Terraform.

Approved sources, exact versions and provider checksums improve dependency verification, but an approved dependency can still contain malicious or vulnerable code. Module allowlisting is not proof of a security review or cryptographic integrity. Source review, provenance verification and vulnerability monitoring are still needed.

Policies need ongoing maintenance as AWS resource types and provider schemas change. Approved versions and lock-file checksums should be updated through reviewed changes, with tests covering new behaviour and unknown plan values. Manually managed HCP policy copies must also stay synchronised with GitHub; otherwise the tested source and hosted checks can diverge.

## Reproducing the checks

Recorded tools: Terraform 1.16.6 locally, 1.17.1 in observed HCP runs, and Sentinel CLI 0.41.0 locally.

From the repository root in PowerShell:

```powershell
Set-Location .\policies
sentinel test

Set-Location ..\terraform
terraform init -backend=false -lockfile=readonly
terraform validate
terraform test
```

The Sentinel suites contain 40 tests cases.

Downloaded real-plan mocks were tested locally using only `tfconfig/v2` and `tfplan/v2`; all five policies passed. Raw downloads were not commited because they contained sensitive values.

## Evidence and interpretation

| Evidence | What it demonstrates |
|---|---|
| [Combined HCP pass log](evidence/hcp-all-policies-advisory-pass.txt) and [screenshot](evidence/hcp-all-policies-advisory-pass.png) | Run `run-S1DQ5gpcnRNCi52w`: all five policies evaluated together and returned true, in advisory mode |
| [Infrastructure rejection log](evidence/hcp-infrastructure-security-advisory-fail.txt) and [screenshot](evidence/hcp-infrastructure-security-advisory-fail.png) | Run `run-xquD9BLa995q9oGp`: `t3.small` caused infrastructure `main`/`instances_secure` to return false; other policies passed |
| [Region failure log](evidence/hcp-approved-regions-fail.txt) and [screenshot](evidence/hcp-approved-regions-fail.png) | Earlier single-policy hard-mandatory check rejected the sandbox plan when the HCP allowlist was temporarily changed to `eu-west-1` |
| [Local supply-chain results](evidence/local-supply-chain-tests.txt) | Positive and negative declaration checks, including untrusted sources and missing or unacceptable versions |
| [Real HCP mock results](evidence/local-hcp-real-plan-policy-results.txt) | Local execution of all five policies against the downloaded HCP configuration and plan |
| [Saved-plan summary](evidence/local-terraform-saved-plan-summary.txt) and [readable plan](terraform/tfplan) | Final local four-resource plan and verified security settings; not an automatic HCP evaluation |

## AI-use declaration

I used GitHub Copilot CLI 1.0.105, powered by GPT-6.1 Sol (model ID `gpt-6.1-sol`), for explanations, Terraform/Sentinel code drafts, writing tests and documentation drafting.

Prompts:

> draft policies for resources and data residency. All services must be created in the eu-west-1, all sensitive data must be stored in eu-west-1. Everything must be replicated within the region only.

> Write code to add the next constrants. Only t2.micro and t3.micro EC2 instances allowed. Encrypted EBS storage and IMDSv2. Network security: unrestricted SSH is not allowed, no public netwrok.

> Add tests and sentinel mocks to cover the policies.

My contribution was choosing the policy rules, dealing with AWS Sandbox limitations, configuring AWS/HCP, creating policies and policy sets, running plans and evaluations, collecting screenshots/logs and managing GitHub branches/merges. AI was used to organize this README and draft some sections.

## References

- [Assignment tutorial: Terraform policy enforcement](https://developer.hashicorp.com/terraform/tutorials/policy)
- [Sentinel policies in HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement)
- [Terraform dependency lock file](https://developer.hashicorp.com/terraform/language/files/dependency-lock)
- [Terraform remote backend](https://developer.hashicorp.com/terraform/language/backend/remote)
- [VPC module 6.0.1](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/6.0.1)
