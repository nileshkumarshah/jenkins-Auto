resource "aws_ecs_task_definition" "report-service" {
  family                = "${var.environment}-${var.service}"
  container_definitions = data.template_file.report_task.rendered
  task_role_arn         = var.task_role
  # tags                  = var.common_tags
}

data "template_file" "report_task" {
  template = file("container-definition.json.tpl")

  vars = {
    application        = "report-service"
    environment        = var.environment
    service            = var.service
    ecr_repo_name      = var.ecr_repo_name
    tag                = var.tag
    region             = var.aws_region
    memory             = var.memory
    cpu                = var.cpu
    port               = var.port
    cloudwatch_group   = "${var.environment}-${var.service}"
    name               = var.service
  }
}
resource "aws_ecs_service" "report_ecs_service" {
  name            = "${var.environment}-${var.service}"
  cluster         = var.clustername
  task_definition = aws_ecs_task_definition.report-service.arn
  # tags            = "${var.common_tags}"
  # propagate_tags  = "TASK_DEFINITION"
  desired_count = var.containers_min
  force_new_deployment = true
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
 lifecycle {
   ignore_changes = [
      capacity_provider_strategy
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service-target-group.arn
    container_name   = var.service
    container_port   = var.port
  }

}
resource "aws_lb_listener_rule" "service-path" {
  listener_arn = var.lb_listener_arn
  priority     = 11

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service-target-group.arn
  }
  condition {
    path_pattern {
      values = [
        "/${var.service}/*"
      ]
    }
  }
}

resource "aws_lb_target_group" "service-target-group" {
  name     = "${var.environment}-${var.service}"
  port     = "8080"
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  deregistration_delay = 120
  # tags     = var.common_tags
  stickiness {
    type = "lb_cookie"
    # Duration for which seconds are sticky in seconds
    cookie_duration = 86400
  }

  health_check {
    path     = "${var.api_health}"
    interval = 70
    timeout  = 60
  }
}
resource "aws_appautoscaling_target" "target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.clustername}/${aws_ecs_service.report_ecs_service.name}"
  role_arn           = var.service_role
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.containers_min
  max_capacity       = var.containers_max
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "${var.environment}-${var.service}-scale-up"
  resource_id        = "service/${var.clustername}/${aws_ecs_service.report_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    aws_appautoscaling_target.target
  ]
}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "${var.environment}-${var.service}-scale-down"
  resource_id        = "service/${var.clustername}/${aws_ecs_service.report_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    aws_appautoscaling_target.target
  ]
}

resource "aws_cloudwatch_metric_alarm" "api_service_memory_high" {
  alarm_name          = "${var.environment}-${var.service}-memory-utilisation-above-70"
  alarm_description   = "This alarm monitors ${var.environment}-${var.service} memory utilisation for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  # tags                = var.common_tags

  dimensions = {
    ClusterName = var.clustername
    ServiceName = aws_ecs_service.report_ecs_service.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.scale_up.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "api_service_memory_low" {
  alarm_name          = "${var.environment}-${var.service}-memory-utilisation-below-5"
  alarm_description   = "This alarm monitors ${var.environment}-${var.service} Memory utilisation for scaling down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "40"
  # tags                = var.common_tags

  dimensions = {
    ClusterName = var.clustername
    ServiceName = aws_ecs_service.report_ecs_service.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.scale_down.arn
  ]
}