
# --------------------------------------------------
# MYSQL ADMINISTRATOR PASSWORD
# --------------------------------------------------

variable "mysql_admin_password" {
  description = "Administrator password for Nova Retail MySQL Flexible Server"
  type        = string
  sensitive   = true
}
