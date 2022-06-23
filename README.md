# platform-opensearch-cloudwatch

This module is designed to be used by anyone with an AWS RDS database instance to easily set up Cloudwatch monitoring.  It is meant to work with any database back end -- MySQL, PostgreSQL, or SQL Server, classic or Aurora.

Default thresholds and period lengths should be reasonable for most; however, most can be overridden as needed.  


The module has a single required input -- db_instance, which must match the name of an opensearch domain existent in the AWS account/region in use.

Variable names for threshold and period overrides can be found in the code.

The module outputs the name of the SNS queue defined as a Cloudwatch topic; configuration of SNS email or Datadog subscriptions should be done in the calling module.
