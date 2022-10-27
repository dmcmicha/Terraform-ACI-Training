terraform {
 required_providers {
 aci = {
 source = "CiscoDevNet/aci"
 }
 }
}
provider "aci" {
 username = "admin"
 password = "C1sco12345"
 url = "https://apic1-a.dcloud.cisco.com"
 insecure = true
}
resource "aci_local_user" "tform_user" {
 name = "tform"
 pwd = "C1sco-321"
 clear_pwd_history = "yes"
}
resource "aci_x509_certificate" "aci_cert" {
 local_user_dn = aci_local_user.tform_user.id
 name = "tform"
 data = <<-EOT
-----BEGIN CERTIFICATE-----
MIICPDCCAaWgAwIBAgIJAM4IisgRy5ATMA0GCSqGSIb3DQEBCwUAMDYxEzARBgNV
BAMMClRlcnJhZm9ybSAxEjAQBgNVBAoMCUNpc2NvTGl2ZTELMAkGA1UEBhMCVVMw
IBcNMjIxMDE3MTkzMzM4WhgPMjEyMjA5MjMxOTMzMzhaMDYxEzARBgNVBAMMClRl
cnJhZm9ybSAxEjAQBgNVBAoMCUNpc2NvTGl2ZTELMAkGA1UEBhMCVVMwgZ8wDQYJ
KoZIhvcNAQEBBQADgY0AMIGJAoGBAL1ITSlIV22z/jnVqFbTXiiHD27ihVCGMmTT
f3xr6o+yneTWZIxD7sY48ZdVqxKOCEPOjioLqmMUsVPRmvN6EWw7kmcPB+j6hi6Z
bIK6qQZ0YBHrOu+zLmV+SWCMRcO5FDVq/KMeonT1ODOyTvq/JSCL5OYk6tL1orUZ
LgI/Xs8dAgMBAAGjUDBOMB0GA1UdDgQWBBSXnu+8SqZBniKXLfp2St2ZzJ9YnDAf
BgNVHSMEGDAWgBSXnu+8SqZBniKXLfp2St2ZzJ9YnDAMBgNVHRMEBTADAQH/MA0G
CSqGSIb3DQEBCwUAA4GBABpMDTIzWxWktjD0cHZBT3vSqL5c+nw5GtQ7Xy45u8Ts
UN290RWa6gvTQyspHRkz6gUUd2OFCaehUp4WElrJ7UTvHd5UgNbatiS5Bnp6GgGi
3hDDhlhqn3T9JnpgQaz5Bvsjy1ko3gDcobKgHPl7i3U3BYmpNGLTSa4yPPHPDNd6
-----END CERTIFICATE-----
EOT
}
resource "aci_rest_managed" "aaaUserDomain_all" {
 dn = "${aci_local_user.tform_user.id}/userdomain-all"
 class_name = "aaaUserDomain"
 content = {
 "name" = "all"
 }
}
resource "aci_rest_managed" "aaaUserRole_admin" {
 dn = "${aci_rest_managed.aaaUserDomain_all.id}/role-admin"
 class_name = "aaaUserRole"
 content = {
 "name" = "admin"
 "privType" = "writePriv"
 }
}