variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "tags" {
  type    = string
  default = "tf.vpc"
}
variable "dns_hostname" {
  type    = bool
  default = true
}
variable "dns_resolution" {
  type    = bool
  default = true
}
variable "assign_public_ip" {
  type    = bool
  default = true

}
variable "required_subnet" {
  type = string
  //default = "2"

}


/* variable "private_enable" {
    type = string
  
} */
variable "public_enable" {
  type = bool

}
variable "private_enable" {
  type = bool
}
variable "test" {
  type    = list(number)
  default = [1, 2, 3]


}
