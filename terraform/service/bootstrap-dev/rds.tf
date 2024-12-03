locals {
    aws_rds_kms_arn = "arn:aws:kms:ap-northeast-2:585334730246:key/05d38942-5433-4ff0-915b-97ec411ca9e5"
}

data "local_sensitive_file" "secret" {
    filename = "${path.module}/secret.json"
}

resource "aws_db_subnet_group" "bootstrap_dev_db_subnet_group" {
    name        = "bootstrap-db-subnet"
    description = "bootstrap db subnet group"
    subnet_ids  = [
        data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_private_subnet_0_id,
        data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_private_subnet_1_id
    ]
    tags        = {
        Role        = "bootstrap"
        Type        = "database"
        Profile     = "dev"
        ManagedBy   = "terraform"
    }
}

resource "aws_db_instance" "bootstrap_dev_db_instance" {
    db_name                               = "bootstrap"
    username                              = "bootstrap_dev"
    password                              = jsondecode(data.local_sensitive_file.secret.content).db_password
    allocated_storage                     = 20
    max_allocated_storage                 = 100
    apply_immediately                     = true
    auto_minor_version_upgrade            = true
    deletion_protection                   = true
    copy_tags_to_snapshot                 = true
    skip_final_snapshot                   = true
    instance_class                        = "db.t3.small"
    engine                                = "postgres"
    engine_version                        = "15.3"
    port                                  = 5432
    publicly_accessible                   = false
    identifier                            = "bootstrap-dev-db" // if ommit, new instance with random id
    backup_retention_period               = 7
    backup_window                         = "16:18-16:48"
    maintenance_window                    = "tue:17:46-tue:18:16" // in UTC.
    multi_az                              = false
    option_group_name                     = "default:postgres-15"
    parameter_group_name                  = "default.postgres15"
    storage_type                          = "gp2"
    storage_encrypted                     = true
    kms_key_id                            = local.aws_rds_kms_arn
    vpc_security_group_ids = [
        data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_db_sg_id
    ]

    db_subnet_group_name = "${aws_db_subnet_group.bootstrap_dev_db_subnet_group.name}"

    tags        = {
        Role        = "bootstrap"
        Type        = "database"
        Profile     = "dev"
        ManagedBy   = "terraform"
    }
}

output "bootstrap_dev_db_instance_domain_name" {
    value = "${aws_db_instance.bootstrap_dev_db_instance.address}"
}
