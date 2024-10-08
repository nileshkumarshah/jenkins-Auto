variable "environment" {
    type= string
    default= "uat"
}
variable "aws_region" {
    type= string
    default="ap-south-1"
}
variable "ecr_repo_name" {
    type= string
    default="stech-devops-repository"
}
variable "deployment_tag" {
    type= string
    default="report-deployment"
}
variable "memory" {
    type= number
    default=1024
}
variable "cpu" {
    type= number
    default= 256
}
variable "port" {
    type= number
    default=8080
}
variable "service" {
    type= string
    default="report"
}
variable "api_health"{
    type=string
    default="/report/api/health"
}
variable "vpc_id" {
    type= string
    default="vpc-0ef1c9227de196b"
}
variable "common_tags" {
    type= string
    default="report-common"
}
variable "containers_min" {
    type= number
    default=1
}
variable "containers_max" {
    type= number
    default=2
}
variable "clustername" {
    type= string
    default="STech-Devops-Preprod"
}
variable "lb_listener_arn"{
    type = string
    default="arn:aws:elasticloadbalancing:ap-south-1:3059049023:listener/app/Devops-ALB/e1dd7790c5b34474/2b8b3ad1ea006326"
}
variable "service_role"{
    type= string
    default= "arn:aws:iam::30594949023:role/ecs-service-autoscale-role"
}
variable "task_role"{
    type= string
    default= "arn:aws:iam::30594904023:role/ecs-test-task-role"
}
variable "tag"{ 
    type= string
    default="report-latest"
}
