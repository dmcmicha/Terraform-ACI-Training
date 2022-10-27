/* Variables for our three-tier application */
variable "tenant_name" {
 default = "dmcmicha-DEMO"
}
variable "vrf_name" {
 default = "dmcmicha_vrf"
}
variable "bd_name" {
 type = list(string)
 default = ["web_bd", "app_bd", "db_bd"]
}
variable "epg_name" {
 type = list(string)
 default = ["web_epg", "app_epg", "db_epg"]
}
variable "ap_name" {
 default = "ecommerce_ap"
}