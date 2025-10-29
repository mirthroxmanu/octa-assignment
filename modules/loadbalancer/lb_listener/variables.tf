variable "load_balancer_arn" {
  description = "arn for the loadbalance for the listener to be attached"
}

variable "listener_port" {
  description = " Port on which the load balancer is listening. Not valid for Gateway Load Balancers."
}

variable "listener_protocol" {
  description = "Protocol for connections from clients to the load balancer. For Application Load Balancers, valid values are HTTP and HTTPS, with a default of HTTP. For Network Load Balancers, valid values are TCP, TLS, UDP, and TCP_UDP. Not valid to use UDP or TCP_UDP if dual-stack mode is enabled. Not valid for Gateway Load Balancers."
}

variable "ssl_certificate_arn" {
  description = "ssl certificate arn aaplicable for 443"
}

