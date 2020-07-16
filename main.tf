provider "nsxt" {
  host                 = var.host
  vmc_token            = var.vmc_token
  allow_unverified_ssl = true
  enforcement_point    = "vmc-enforcementpoint"
}

###################### creating Groups ######################

// creating Group for Druva_Proxy:
resource "nsxt_policy_group" "Druva_Proxy" {
  display_name = "Druva_Proxy"
  description  = "Created from Terraform Druva_Proxy"
  domain       = "cgw"
}

// creating Group for Druva_Cache:
resource "nsxt_policy_group" "Druva_Cache" {
  display_name = "Druva_Cache"
  description  = "Created from Terraform Druva_Cache"
  domain       = "cgw"
}

// creating Group for SQL-Server:
resource "nsxt_policy_group" "SQL-Server" {
  display_name = "SQL-Server"
  description  = "Created from Terraform SQL-Server"
  domain       = "cgw"
}

// creating Group for RFC_1918:
resource "nsxt_policy_group" "RFC_1918" {
  display_name = "RFC_1918"
  description  = "Created from Terraform RFC_1918"
  domain       = "cgw"

    criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.0.0/16", "172.16.0.0/16", "10.0.0.0/8"]
    }
  }
}

###################### creating Services ######################

// creating Services TCP 3542:
resource "nsxt_policy_service" "Druva_Restore_SQL" {
  description  = "Druva_Restore_SQL provisioned by Terraform"
  display_name = "Druva_Restore_SQL TCP3542"

  l4_port_set_entry {
    display_name      = "TCP3542"
    description       = "TCP port 3542 entry"
    protocol          = "TCP"
    destination_ports = ["3542"]
  }
}

###################### creating DFW Security Rules ######################

###################### creating Ruleset for Cloud Proxy ######################

resource "nsxt_policy_security_policy" "Druva_Proxy" {
  domain       = "cgw"
  display_name = "Druva_Proxy"
  description  = "Terraform Druva_Proxy Ruleset"
  category     = "Application"
  rule {
    display_name       = "Allow_vCenter_outbound"
    source_groups      = ["${nsxt_policy_group.Druva_Proxy.path}", "${nsxt_policy_group.Druva_Cache.path}"]
    destination_groups = ["/infra/domains/mgw/groups/VCENTER"]
    action             = "ALLOW"
    services           = ["/infra/services/HTTPS"]
    logged             = true
  }
  rule {
    display_name       = "Allow_vCenter_inbound"
    source_groups      = ["/infra/domains/mgw/groups/VCENTER"]
    destination_groups = ["${nsxt_policy_group.Druva_Proxy.path}", "${nsxt_policy_group.Druva_Cache.path}"]
    action             = "ALLOW"
    services           = ["/infra/services/HTTPS"]
    logged             = true
  }
/* ###################### ESXi access is not needed! ######################
 rule {
    display_name       = "Allow_ESXi_outbound"
    source_groups      = ["${nsxt_policy_group.Druva_Proxy.path}", "${nsxt_policy_group.Druva_Cache.path}"]
    destination_groups = ["/infra/domains/mgw/groups/ESXI"]
    action             = "ALLOW"
    services           = ["/infra/services/VMware_Remote_Console"]
    logged             = true
  }*/
  rule {
    display_name       = "Allow_Restore_SQL_Outbound"
    source_groups      = ["${nsxt_policy_group.Druva_Proxy.path}", "${nsxt_policy_group.Druva_Cache.path}"]
    destination_groups = ["${nsxt_policy_group.SQL-Server.path}"]
    action             = "ALLOW"
    services           = ["${nsxt_policy_service.Druva_Restore_SQL.path}"]
    logged             = true
  }
  rule {
    display_name       = "Internet_Access"
    source_groups      = ["${nsxt_policy_group.Druva_Proxy.path}", "${nsxt_policy_group.Druva_Cache.path}"]
    destination_groups = ["${nsxt_policy_group.RFC_1918.path}"]
    destinations_excluded = true
    action             = "ALLOW"
    services           = ["/infra/services/HTTPS"]
    logged             = true
  }
  rule {
    display_name       = "Deny_Traffic_Outbound"
    source_groups      = ["${nsxt_policy_group.Druva_Proxy.path}", "${nsxt_policy_group.Druva_Cache.path}"]
    destination_groups = []
    action             = "REJECT"
    disabled           = true
    services           = []
    logged             = true
  }
  rule {
      display_name       = "Deny_Traffic_Inbound"
      source_groups      = []
      destination_groups = ["${nsxt_policy_group.Druva_Proxy.path}", "${nsxt_policy_group.Druva_Cache.path}"]
      action             = "REJECT"
      disabled           = true
      services           = []
      logged             = true
    }
}

###################### creating Management Gateway Firewall rule ######################
            ###################### not possible yet ######################
/*
resource "nsxt_policy_gateway_policy" "mgw_policy" {
  category     = "LocalGatewayRules"
  display_name = "default"
  domain       = "mgw"
  rule {
    action = "ALLOW"
    destination_groups = ["/infra/domains/mgw/groups/VCENTER"]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "vCenter Inbound set up by Terraform"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope = [
      "/infra/labels/mgw",
    ]
    services = [
      "/infra/services/HTTPS",
      "/infra/services/ICMP-ALL",
    ]
    source_groups    = ["${nsxt_policy_group.Druva_Proxy.path}"]
    sources_excluded = false
  }
}

###################### creating Compute Gateway Firewall rule ######################
            ###################### not possible yet ######################
resource "nsxt_policy_gateway_policy" "cgw_policy" {
  category     = "LocalGatewayRules"
  display_name = "default"
  domain       = "cgw"
  rule {
    action = "ALLOW"
    destination_groups = ["/infra/domains/mgw/groups/VCENTER"]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "vCenter Inbound set up by Terraform"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope = [
      "/infra/labels/cgw",
    ]
    services = [
      "/infra/services/HTTPS",
      "/infra/services/ICMP-ALL",
    ]
    source_groups    = ["${nsxt_policy_group.Druva_Proxy.path}"]
    sources_excluded = false
  }
  rule {
    action = "ALLOW"
    destination_groups = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "Druva Internet access set up by Terraform"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope = [
      "/infra/labels/cgw",
    ]
    services = [
      "/infra/services/HTTPS"
    ]
    source_groups    = ["${nsxt_policy_group.Druva_Proxy.path}"]
    sources_excluded = false
  }
}
*/
