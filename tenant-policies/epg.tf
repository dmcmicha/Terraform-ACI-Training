/*
 Creates the Application Profile and configures
 the EPGs -> Web, App, DB. Will be associated to contracts
 in a separate .tf file
*/
resource "aci_application_profile" "terraform_ap" {
 tenant_dn = aci_tenant.terraform_tenant.id
 name = var.ap_name
}
resource "aci_application_epg" "web_epg" {
 description = "Created with Terraform"
 application_profile_dn = aci_application_profile.terraform_ap.id
 name = var.epg_name[0]
 relation_fv_rs_bd = aci_bridge_domain.web-bd.id
 relation_fv_rs_prov = [aci_contract.web_app.id]
}
resource "aci_epg_to_domain" "web-domain" {
  application_epg_dn    = aci_application_epg.web_epg.id
  tdn                   = "uni/phys-tf-domain"
}
resource "aci_epg_to_static_path" "web_static" {
    description = "Created with Terraform"
    application_epg_dn  = aci_application_epg.web_epg.id
    tdn  = "topology/pod-1/paths-101/pathep-[eth1/20]"
    encap = "vlan-121"
    #primary_encap  = "vlan-121"
    mode  = "regular"
    instr_imedcy = "immediate"
}

resource "aci_application_epg" "app_epg" {
 description = "Created with Terraform"
 application_profile_dn = aci_application_profile.terraform_ap.id
 name = var.epg_name[1]
 relation_fv_rs_bd = aci_bridge_domain.app-bd.id
 relation_fv_rs_cons = [aci_contract.web_app.id]
 relation_fv_rs_prov = [aci_contract.app_db.id]
}
resource "aci_epg_to_domain" "app-domain" {
  application_epg_dn    = aci_application_epg.app_epg.id
  tdn                   = "uni/phys-tf-domain"
}
resource "aci_epg_to_static_path" "app_static" {
    description = "Created with Terraform"
    application_epg_dn  = aci_application_epg.app_epg.id
    tdn  = "topology/pod-1/paths-101/pathep-[eth1/20]"
    encap = "vlan-122"
    #primary_encap  = "vlan-122"
    mode  = "regular"
    instr_imedcy = "immediate"
}

resource "aci_application_epg" "db_epg" {
 description = "Created with Terraform"
 application_profile_dn = aci_application_profile.terraform_ap.id
 name = var.epg_name[2]
 relation_fv_rs_bd = aci_bridge_domain.db-bd.id
 relation_fv_rs_cons = [aci_contract.app_db.id]
}
resource "aci_epg_to_domain" "db-domain" {
  application_epg_dn    = aci_application_epg.db_epg.id
  tdn                   = "uni/phys-tf-domain"
}
resource "aci_epg_to_static_path" "db_static" {
    description = "Created with Terraform"
    application_epg_dn  = aci_application_epg.db_epg.id
    tdn  = "topology/pod-1/paths-101/pathep-[eth1/20]"
    encap = "vlan-123"
    #primary_encap  = "vlan-123"
    mode  = "regular"
    instr_imedcy = "immediate"
}