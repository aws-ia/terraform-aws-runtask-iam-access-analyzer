{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ValidPermission",
            "Action": [
                "lambda:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Sid": "InvalidPermission",
            "Action": "events:PutEvent",
            "Resource": "arn:${aws_partition}:${aws_service}:${aws_region}:${aws_account_id}:event-bus/${name_prefix}",
            "Effect": "Allow"
        }
    ]
}