# Digital Sovereignty and IaC Supply-Chain Security

## Implementation and results

Five Sentinel policies evaluate approved AWS regions, supported storage and replication residency, EC2/EBS/IMDSv2/network security, and provider/module declarations. The Terraform example plans a private VPC, subnet, security group and t2.micro instance with encrypted root EBS and IMDSv2. Forty local policy fixture cases cover expected acceptance and rejection. All five policies passed together in HCP and against downloaded real-plan mocks. A t3.small example failed the infrastructure rule; an earlier region experiment failed a hard-mandatory check. A binary plan was saved separately, with reviewed readable output in terraform/tfplan. No infrastructure was applied.

## Final limitations

**Residency is not sovereignty.** The sandbox uses us-east-1, not Ireland's eu-west-1. Its results therefore do not establish Irish residency. Region restrictions do not determine provider jurisdiction, administrator access, legal demands or control of encryption keys. Only supported S3/EBS/EC2 storage and S3/EBS copy operations are covered; runtime transfers and other services remain outside scope.

**Detection is not always prevention.** The final five-policy HCP demonstration is advisory because my current setup only permitted one hard-mandatory policy. An advisory rule can fail while the overall check remains allowed. Repository configuration specifies hard-mandatory, but combined blocking enforcement was not demonstrated. Privileged administrators can also change policies.

**Plan visibility and trust are bounded.** Policies examine supported configuration expressions and managed planned resources, not all existing infrastructure or out-of-band changes. The live example has no modules or replication; those behaviours are exercised by synthetic cases. Provider allowlists and exact versions do not establish package safety. Terraform verifies provider lock-file checksums; the lock file does not secure module contents. The allowlisted VPC module is not Registry verified. The latest-matching AMI lookup is another unpinned dependency.

## Recommendations

For production, use eu-west-1 consistently, hard-mandatory policies and disabled overrides; govern policy administration and audit access. Add service-specific residency, backup/restore and customer-key controls. Review dependency and image provenance, monitor vulnerabilities and update approved versions/checksums through reviewed changes. Expand tests as AWS schemas evolve and keep manually managed HCP policy copies synchronised with GitHub. Preserve execution evidence and never publish credential-bearing mock downloads.
