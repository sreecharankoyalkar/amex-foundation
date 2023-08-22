# Copyright 2021 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreement with Google.

/************************************************
  Bootstrap GCP Organization.
*************************************************/

resource "random_id" "suffix" {
  byte_length = 3
}
resource "time_static" "created" {}

locals {
  created = replace(split("T", time_static.created.rfc3339)[0], "-", "")
  labels  = merge(var.project_labels, { "created" : local.created })

}

resource "google_folder" "bootstrap" {
  display_name = var.bootstrap_folder
  parent       = "organizations/${var.org_id}"
}


/************************************************
  Create custom roles. 
*************************************************/

/*##################################
  Custom Role AmexProjectCreatorRole
*/##################################

/***** AmexProjectCreatorRole Permissions

  - "resourcemanager.organizations.get",
  - "resourcemanager.projects.create"

*****/

module "project_creator_role" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level = "org"
  target_id    = var.org_id
  role_id      = "AmexProjectCreatorRole"
  title        = "custom project creator Role"
  description  = "This role has all needed permissions to create projects"
  base_roles   = ["roles/resourcemanager.projectCreator"]
  members      = ["group:${var.group_org_admins}", "serviceAccount:${google_service_account.org_terraform.email}"]
  permissions  = []
}

/*############################
  Custom Role AmexBillingAdmin
*/############################

/***** AmexBillingAdmin Permissions 

  - "billing.accounts.close",
  - "billing.accounts.get",
  - "billing.accounts.getIamPolicy",
  - "billing.accounts.getPaymentInfo",
  - "billing.accounts.getPricing",
  - "billing.accounts.getSpendingInformation",
  - "billing.accounts.getUsageExportSpec",
  - "billing.accounts.list",
  - "billing.accounts.move",
  - "billing.accounts.redeemPromotion",
  - "billing.accounts.removeFromOrganization",
  - "billing.accounts.reopen",
  - "billing.accounts.setIamPolicy",
  - "billing.accounts.update",
  - "billing.accounts.updatePaymentInfo",
  - "billing.accounts.updateUsageExportSpec",
  - "billing.budgets.create",
  - "billing.budgets.delete",
  - "billing.budgets.get",
  - "billing.budgets.list",
  - "billing.budgets.update",
  - "billing.credits.list",
  - "billing.resourceAssociations.create",
  - "billing.resourceAssociations.delete",
  - "billing.resourceAssociations.list",
  - "billing.subscriptions.create",
  - "billing.subscriptions.get",
  - "billing.subscriptions.list",
  - "billing.subscriptions.update",
  - "cloudnotifications.activities.list",
  - "commerceoffercatalog.offers.get",
  - "consumerprocurement.accounts.create",
  - "consumerprocurement.accounts.delete",
  - "consumerprocurement.accounts.get",
  - "consumerprocurement.accounts.list",
  - "consumerprocurement.orders.cancel",
  - "consumerprocurement.orders.get",
  - "consumerprocurement.orders.list",
  - "consumerprocurement.orders.modify",
  - "consumerprocurement.orders.place",
  - "dataprocessing.datasources.get",
  - "dataprocessing.datasources.list",
  - "dataprocessing.groupcontrols.get",
  - "dataprocessing.groupcontrols.list",
  - "logging.logEntries.list",
  - "logging.logServiceIndexes.list",
  - "logging.logServices.list",
  - "logging.logs.list",
  - "logging.privateLogEntries.list",
  - "recommender.commitmentUtilizationInsights.get",
  - "recommender.commitmentUtilizationInsights.list",
  - "recommender.commitmentUtilizationInsights.update",
  - "recommender.usageCommitmentRecommendations.get",
  - "recommender.usageCommitmentRecommendations.list",
  - "recommender.usageCommitmentRecommendations.update",
  - "resourcemanager.projects.createBillingAssignment",
  - "resourcemanager.projects.deleteBillingAssignment"

*****/

module "billing_admin_role" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level = "org"
  target_id    = var.org_id
  role_id      = "AmexBillingAdmin"
  title        = "custom billing admin role"
  description  = "Provides access to see and manage all aspects of billing accounts"
  base_roles   = ["roles/billing.admin"]
  members      = ["group:${var.group_org_admins}"]
  permissions  = []
}

/*##############################
  Custom Role AmexBillingUser
*/##############################

/***** AmexBillingUser Permissions

  - "billing.accounts.get",
  - "billing.accounts.getIamPolicy",
  - "billing.accounts.list",
  - "billing.accounts.redeemPromotion",
  - "billing.credits.list",
  - "billing.resourceAssociations.create"

*****/

module "billing_user_role" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level = "org"
  target_id    = var.org_id
  role_id      = "AmexBillingUser"
  title        = "custom billing user role"
  description  = "Provides access to associate projects with billing accounts"
  base_roles   = ["roles/billing.user"]
  members      = ["serviceAccount:${google_service_account.org_terraform.email}"]
  permissions  = []
}

/*##############################
  Custom Role AmexBillingCreator
*/##############################

/***** AmexBillingCreator Permissions

  - "billing.accounts.create",
  - "resourcemanager.organizations.get"

*****/

module "billing_creator_role" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level = "org"
  target_id    = var.org_id
  role_id      = "AmexBillingCreator"
  title        = "custom billing creator role"
  description  = "Provides access to create billing accounts"
  base_roles   = ["roles/billing.creator"]
  members      = ["group:${var.group_org_admins}"]
  permissions  = []
}

/*#############################
  Custom Role AmexSecurityAdmin
*/#############################

/**** AmexSecurityAdmin Permissions

accessapproval.requests.list
accesscontextmanager.accessLevels.list
accesscontextmanager.accessPolicies.getIamPolicy
accesscontextmanager.accessPolicies.list
accesscontextmanager.accessPolicies.setIamPolicy
accesscontextmanager.accessZones.list
accesscontextmanager.gcpUserAccessBindings.list
accesscontextmanager.policies.getIamPolicy
accesscontextmanager.policies.list
accesscontextmanager.policies.setIamPolicy
accesscontextmanager.servicePerimeters.list
actions.agentVersions.list
aiplatform.annotationSpecs.list
aiplatform.annotations.list
aiplatform.artifacts.list
aiplatform.batchPredictionJobs.list
aiplatform.contexts.list
aiplatform.customJobs.list
aiplatform.dataItems.list
aiplatform.dataLabelingJobs.list
aiplatform.datasets.list
aiplatform.edgeDeploymentJobs.list
aiplatform.edgeDevices.list
aiplatform.endpoints.list
aiplatform.entityTypes.list
aiplatform.executions.list
aiplatform.features.list
aiplatform.featurestores.list
aiplatform.humanInTheLoops.list
aiplatform.hyperparameterTuningJobs.list
aiplatform.indexEndpoints.list
aiplatform.indexes.list
aiplatform.locations.list
aiplatform.metadataSchemas.list
aiplatform.metadataStores.list
aiplatform.modelDeploymentMonitoringJobs.list
aiplatform.modelEvaluationSlices.list
aiplatform.modelEvaluations.list
aiplatform.models.list
aiplatform.nasJobs.list
aiplatform.operations.*
aiplatform.pipelineJobs.list
aiplatform.specialistPools.list
aiplatform.studies.list
aiplatform.tensorboardExperiments.list
aiplatform.tensorboardRuns.list
aiplatform.tensorboardTimeSeries.list
aiplatform.tensorboards.list
aiplatform.trainingPipelines.list
aiplatform.trials.list
apigateway.apiconfigs.getIamPolicy
apigateway.apiconfigs.list
apigateway.apiconfigs.setIamPolicy
apigateway.apis.getIamPolicy
apigateway.apis.list
apigateway.apis.setIamPolicy
apigateway.gateways.getIamPolicy
apigateway.gateways.list
apigateway.gateways.setIamPolicy
apigateway.locations.list
apigateway.operations.list
apigee.apiproductattributes.list
apigee.apiproducts.list
apigee.apps.list
apigee.archivedeployments.list
apigee.caches.list
apigee.datacollectors.list
apigee.datastores.list
apigee.deployments.list
apigee.developerappattributes.list
apigee.developerapps.list
apigee.developerattributes.list
apigee.developers.list
apigee.developersubscriptions.list
apigee.envgroupattachments.list
apigee.envgroups.list
apigee.environments.getIamPolicy
apigee.environments.list
apigee.environments.setIamPolicy
apigee.exports.list
apigee.flowhooks.list
apigee.hostqueries.list
apigee.hostsecurityreports.list
apigee.instanceattachments.list
apigee.instances.list
apigee.keystorealiases.list
apigee.keystores.list
apigee.keyvaluemaps.list
apigee.operations.list
apigee.organizations.list
apigee.portals.list
apigee.proxies.list
apigee.proxyrevisions.list
apigee.queries.list
apigee.rateplans.list
apigee.references.list
apigee.reports.list
apigee.resourcefiles.list
apigee.securityreports.list
apigee.sharedflowrevisions.list
apigee.sharedflows.list
apigee.targetservers.list
apigee.tracesessions.list
apigeeconnect.connections.*
apikeys.keys.list
appengine.instances.list
appengine.memcache.list
appengine.operations.list
appengine.services.list
appengine.versions.list
artifactregistry.files.list
artifactregistry.packages.list
artifactregistry.repositories.getIamPolicy
artifactregistry.repositories.list
artifactregistry.repositories.setIamPolicy
artifactregistry.tags.list
artifactregistry.versions.list
assuredworkloads.operations.list
assuredworkloads.workload.list
automl.annotationSpecs.list
automl.annotations.list
automl.columnSpecs.list
automl.datasets.getIamPolicy
automl.datasets.list
automl.datasets.setIamPolicy
automl.examples.list
automl.humanAnnotationTasks.list
automl.locations.getIamPolicy
automl.locations.list
automl.locations.setIamPolicy
automl.modelEvaluations.list
automl.models.getIamPolicy
automl.models.list
automl.models.setIamPolicy
automl.operations.list
automl.tableSpecs.list
automlrecommendations.apiKeys.list
automlrecommendations.catalogItems.list
automlrecommendations.catalogs.list
automlrecommendations.events.list
automlrecommendations.placements.list
automlrecommendations.recommendations.list
autoscaling.sites.getIamPolicy
autoscaling.sites.setIamPolicy
baremetalsolution.instances.list
bigquery.capacityCommitments.list
bigquery.connections.getIamPolicy
bigquery.connections.list
bigquery.connections.setIamPolicy
bigquery.datasets.getIamPolicy
bigquery.datasets.setIamPolicy
bigquery.jobs.list
bigquery.models.list
bigquery.reservationAssignments.list
bigquery.reservations.list
bigquery.routines.list
bigquery.rowAccessPolicies.getIamPolicy
bigquery.rowAccessPolicies.list
bigquery.rowAccessPolicies.setIamPolicy
bigquery.savedqueries.list
bigquery.tables.getIamPolicy
bigquery.tables.list
bigquery.tables.setIamPolicy
bigtable.appProfiles.list
bigtable.backups.getIamPolicy
bigtable.backups.list
bigtable.backups.setIamPolicy
bigtable.clusters.list
bigtable.instances.getIamPolicy
bigtable.instances.list
bigtable.instances.setIamPolicy
bigtable.keyvisualizer.list
bigtable.locations.*
bigtable.tables.getIamPolicy
bigtable.tables.list
bigtable.tables.setIamPolicy
billing.accounts.getIamPolicy
billing.accounts.list
billing.accounts.setIamPolicy
billing.budgets.list
billing.credits.*
billing.resourceAssociations.list
billing.subscriptions.list
binaryauthorization.attestors.getIamPolicy
binaryauthorization.attestors.list
binaryauthorization.attestors.setIamPolicy
binaryauthorization.continuousValidationConfig.getIamPolicy
binaryauthorization.continuousValidationConfig.setIamPolicy
binaryauthorization.policy.getIamPolicy
binaryauthorization.policy.setIamPolicy
clientauthconfig.brands.list
clientauthconfig.clients.list
cloudasset.assets.searchAllResources
cloudasset.feeds.list
cloudbuild.builds.list
cloudbuild.workerpools.list
clouddebugger.breakpoints.list
clouddebugger.debuggees.list
clouddeploy.deliveryPipelines.getIamPolicy
clouddeploy.deliveryPipelines.list
clouddeploy.deliveryPipelines.setIamPolicy
clouddeploy.locations.list
clouddeploy.operations.list
clouddeploy.releases.list
clouddeploy.rollouts.list
clouddeploy.targets.getIamPolicy
clouddeploy.targets.list
clouddeploy.targets.setIamPolicy
cloudfunctions.functions.getIamPolicy
cloudfunctions.functions.list
cloudfunctions.functions.setIamPolicy
cloudfunctions.locations.list
cloudfunctions.operations.list
cloudiot.devices.list
cloudiot.registries.getIamPolicy
cloudiot.registries.list
cloudiot.registries.setIamPolicy
cloudjobdiscovery.companies.list
cloudkms.cryptoKeyVersions.list
cloudkms.cryptoKeys.getIamPolicy
cloudkms.cryptoKeys.list
cloudkms.cryptoKeys.setIamPolicy
cloudkms.importJobs.getIamPolicy
cloudkms.importJobs.list
cloudkms.importJobs.setIamPolicy
cloudkms.keyRings.getIamPolicy
cloudkms.keyRings.list
cloudkms.keyRings.setIamPolicy
cloudkms.locations.list
cloudnotifications.*
cloudonefs.isiloncloud.com/clusters.list
cloudonefs.isiloncloud.com/fileshares.list
cloudprivatecatalogproducer.associations.list
cloudprivatecatalogproducer.catalogAssociations.list
cloudprivatecatalogproducer.catalogs.getIamPolicy
cloudprivatecatalogproducer.catalogs.list
cloudprivatecatalogproducer.catalogs.setIamPolicy
cloudprivatecatalogproducer.producerCatalogs.getIamPolicy
cloudprivatecatalogproducer.producerCatalogs.list
cloudprivatecatalogproducer.producerCatalogs.setIamPolicy
cloudprivatecatalogproducer.products.getIamPolicy
cloudprivatecatalogproducer.products.list
cloudprivatecatalogproducer.products.setIamPolicy
cloudprofiler.profiles.list
cloudscheduler.jobs.list
cloudscheduler.locations.list
cloudsecurityscanner.crawledurls.*
cloudsecurityscanner.results.list
cloudsecurityscanner.scanruns.list
cloudsecurityscanner.scans.list
cloudsql.backupRuns.list
cloudsql.databases.list
cloudsql.instances.list
cloudsql.sslCerts.list
cloudsql.users.list
cloudsupport.accounts.getIamPolicy
cloudsupport.accounts.list
cloudsupport.accounts.setIamPolicy
cloudsupport.techCases.list
cloudtasks.locations.list
cloudtasks.queues.getIamPolicy
cloudtasks.queues.list
cloudtasks.queues.setIamPolicy
cloudtasks.tasks.list
cloudtoolresults.executions.list
cloudtoolresults.histories.list
cloudtoolresults.steps.list
cloudtrace.insights.list
cloudtrace.tasks.list
cloudtrace.traces.list
cloudtranslate.glossaries.list
cloudtranslate.locations.list
cloudtranslate.operations.list
cloudvolumesgcp-api.netapp.com/activeDirectories.list
cloudvolumesgcp-api.netapp.com/ipRanges.*
cloudvolumesgcp-api.netapp.com/jobs.list
cloudvolumesgcp-api.netapp.com/regions.*
cloudvolumesgcp-api.netapp.com/serviceLevels.*
cloudvolumesgcp-api.netapp.com/snapshots.list
cloudvolumesgcp-api.netapp.com/volumes.list
commerceprice.privateoffers.list
composer.environments.list
composer.imageversions.*
composer.operations.list
compute.acceleratorTypes.list
compute.addresses.list
compute.autoscalers.list
compute.backendBuckets.list
compute.backendServices.getIamPolicy
compute.backendServices.list
compute.backendServices.setIamPolicy
compute.commitments.list
compute.diskTypes.list
compute.disks.getIamPolicy
compute.disks.list
compute.disks.setIamPolicy
compute.externalVpnGateways.list
compute.firewallPolicies.getIamPolicy
compute.firewallPolicies.list
compute.firewallPolicies.setIamPolicy
compute.firewalls.list
compute.forwardingRules.list
compute.globalAddresses.list
compute.globalForwardingRules.list
compute.globalNetworkEndpointGroups.list
compute.globalOperations.getIamPolicy
compute.globalOperations.list
compute.globalOperations.setIamPolicy
compute.globalPublicDelegatedPrefixes.list
compute.healthChecks.list
compute.httpHealthChecks.list
compute.httpsHealthChecks.list
compute.images.getIamPolicy
compute.images.list
compute.images.setIamPolicy
compute.instanceGroupManagers.list
compute.instanceGroups.list
compute.instanceTemplates.getIamPolicy
compute.instanceTemplates.list
compute.instanceTemplates.setIamPolicy
compute.instances.getIamPolicy
compute.instances.list
compute.instances.setIamPolicy
compute.interconnectAttachments.list
compute.interconnectLocations.list
compute.interconnects.list
compute.licenseCodes.getIamPolicy
compute.licenseCodes.list
compute.licenseCodes.setIamPolicy
compute.licenses.getIamPolicy
compute.licenses.list
compute.licenses.setIamPolicy
compute.machineImages.getIamPolicy
compute.machineImages.list
compute.machineImages.setIamPolicy
compute.machineTypes.list
compute.maintenancePolicies.getIamPolicy
compute.maintenancePolicies.list
compute.maintenancePolicies.setIamPolicy
compute.networkEndpointGroups.getIamPolicy
compute.networkEndpointGroups.list
compute.networkEndpointGroups.setIamPolicy
compute.networks.list
compute.nodeGroups.getIamPolicy
compute.nodeGroups.list
compute.nodeGroups.setIamPolicy
compute.nodeTemplates.getIamPolicy
compute.nodeTemplates.list
compute.nodeTemplates.setIamPolicy
compute.nodeTypes.list
compute.publicAdvertisedPrefixes.list
compute.publicDelegatedPrefixes.list
compute.regionBackendServices.getIamPolicy
compute.regionBackendServices.list
compute.regionBackendServices.setIamPolicy
compute.regionHealthCheckServices.list
compute.regionHealthChecks.list
compute.regionNetworkEndpointGroups.list
compute.regionNotificationEndpoints.list
compute.regionOperations.getIamPolicy
compute.regionOperations.list
compute.regionOperations.setIamPolicy
compute.regionSslCertificates.list
compute.regionTargetHttpProxies.list
compute.regionTargetHttpsProxies.list
compute.regionUrlMaps.list
compute.regions.list
compute.reservations.list
compute.resourcePolicies.list
compute.routers.list
compute.routes.list
compute.securityPolicies.getIamPolicy
compute.securityPolicies.list
compute.securityPolicies.setIamPolicy
compute.serviceAttachments.list
compute.snapshots.getIamPolicy
compute.snapshots.list
compute.snapshots.setIamPolicy
compute.sslCertificates.list
compute.sslPolicies.list
compute.subnetworks.getIamPolicy
compute.subnetworks.list
compute.subnetworks.setIamPolicy
compute.targetGrpcProxies.list
compute.targetHttpProxies.list
compute.targetHttpsProxies.list
compute.targetInstances.list
compute.targetPools.list
compute.targetSslProxies.list
compute.targetTcpProxies.list
compute.targetVpnGateways.list
compute.urlMaps.list
compute.vpnGateways.list
compute.vpnTunnels.list
compute.zoneOperations.getIamPolicy
compute.zoneOperations.list
compute.zoneOperations.setIamPolicy
compute.zones.list
connectors.connections.getIamPolicy
connectors.connections.list
connectors.connections.setIamPolicy
connectors.connectors.list
connectors.locations.list
connectors.operations.list
connectors.providers.list
connectors.versions.list
consumerprocurement.accounts.list
consumerprocurement.entitlements.list
consumerprocurement.freeTrials.list
consumerprocurement.orders.list
contactcenterinsights.analyses.list
contactcenterinsights.conversations.list
contactcenterinsights.issueModels.list
contactcenterinsights.issues.list
contactcenterinsights.operations.list
contactcenterinsights.phraseMatchers.list
container.apiServices.list
container.auditSinks.list
container.backendConfigs.list
container.bindings.list
container.certificateSigningRequests.list
container.clusterRoleBindings.list
container.clusterRoles.list
container.clusters.list
container.componentStatuses.list
container.configMaps.list
container.controllerRevisions.list
container.cronJobs.list
container.csiDrivers.list
container.csiNodeInfos.list
container.csiNodes.list
container.customResourceDefinitions.list
container.daemonSets.list
container.deployments.list
container.endpointSlices.list
container.endpoints.list
container.events.list
container.frontendConfigs.list
container.horizontalPodAutoscalers.list
container.ingresses.list
container.initializerConfigurations.list
container.jobs.list
container.leases.list
container.limitRanges.list
container.localSubjectAccessReviews.list
container.managedCertificates.list
container.mutatingWebhookConfigurations.list
container.namespaces.list
container.networkPolicies.list
container.nodes.list
container.operations.list
container.persistentVolumeClaims.list
container.persistentVolumes.list
container.petSets.list
container.podDisruptionBudgets.list
container.podPresets.list
container.podSecurityPolicies.list
container.podTemplates.list
container.pods.list
container.priorityClasses.list
container.replicaSets.list
container.replicationControllers.list
container.resourceQuotas.list
container.roleBindings.list
container.roles.list
container.runtimeClasses.list
container.scheduledJobs.list
container.selfSubjectAccessReviews.list
container.serviceAccounts.list
container.services.list
container.statefulSets.list
container.storageClasses.list
container.storageStates.list
container.storageVersionMigrations.list
container.subjectAccessReviews.list
container.thirdPartyObjects.list
container.thirdPartyResources.list
container.updateInfos.list
container.validatingWebhookConfigurations.list
container.volumeAttachments.list
container.volumeSnapshotClasses.list
container.volumeSnapshotContents.list
container.volumeSnapshots.list
containeranalysis.notes.getIamPolicy
containeranalysis.notes.list
containeranalysis.notes.setIamPolicy
containeranalysis.occurrences.getIamPolicy
containeranalysis.occurrences.list
containeranalysis.occurrences.setIamPolicy
datacatalog.categories.getIamPolicy
datacatalog.categories.setIamPolicy
datacatalog.entries.getIamPolicy
datacatalog.entries.list
datacatalog.entries.setIamPolicy
datacatalog.entryGroups.getIamPolicy
datacatalog.entryGroups.list
datacatalog.entryGroups.setIamPolicy
datacatalog.tagTemplates.getIamPolicy
datacatalog.tagTemplates.setIamPolicy
datacatalog.taxonomies.getIamPolicy
datacatalog.taxonomies.list
datacatalog.taxonomies.setIamPolicy
dataflow.jobs.list
dataflow.messages.*
dataflow.snapshots.list
datafusion.instances.getIamPolicy
datafusion.instances.list
datafusion.instances.setIamPolicy
datafusion.locations.list
datafusion.operations.list
datalabeling.annotateddatasets.list
datalabeling.annotationspecsets.list
datalabeling.dataitems.list
datalabeling.datasets.list
datalabeling.examples.list
datalabeling.instructions.list
datalabeling.operations.list
datamigration.connectionprofiles.getIamPolicy
datamigration.connectionprofiles.list
datamigration.connectionprofiles.setIamPolicy
datamigration.locations.list
datamigration.migrationjobs.getIamPolicy
datamigration.migrationjobs.list
datamigration.migrationjobs.setIamPolicy
datamigration.operations.list
datapipelines.pipelines.list
dataproc.agents.list
dataproc.autoscalingPolicies.getIamPolicy
dataproc.autoscalingPolicies.list
dataproc.autoscalingPolicies.setIamPolicy
dataproc.clusters.getIamPolicy
dataproc.clusters.list
dataproc.clusters.setIamPolicy
dataproc.jobs.getIamPolicy
dataproc.jobs.list
dataproc.jobs.setIamPolicy
dataproc.operations.getIamPolicy
dataproc.operations.list
dataproc.operations.setIamPolicy
dataproc.workflowTemplates.getIamPolicy
dataproc.workflowTemplates.list
dataproc.workflowTemplates.setIamPolicy
dataprocessing.datasources.list
dataprocessing.featurecontrols.list
dataprocessing.groupcontrols.list
datastore.databases.getIamPolicy
datastore.databases.list
datastore.databases.setIamPolicy
datastore.entities.list
datastore.indexes.list
datastore.locations.list
datastore.namespaces.getIamPolicy
datastore.namespaces.list
datastore.namespaces.setIamPolicy
datastore.operations.list
datastore.statistics.list
datastream.connectionProfiles.getIamPolicy
datastream.connectionProfiles.list
datastream.connectionProfiles.setIamPolicy
datastream.locations.list
datastream.operations.list
datastream.privateConnections.getIamPolicy
datastream.privateConnections.list
datastream.privateConnections.setIamPolicy
datastream.routes.getIamPolicy
datastream.routes.list
datastream.routes.setIamPolicy
datastream.streams.getIamPolicy
datastream.streams.list
datastream.streams.setIamPolicy
deploymentmanager.compositeTypes.list
deploymentmanager.deployments.getIamPolicy
deploymentmanager.deployments.list
deploymentmanager.deployments.setIamPolicy
deploymentmanager.manifests.list
deploymentmanager.operations.list
deploymentmanager.resources.list
deploymentmanager.typeProviders.list
deploymentmanager.types.list
dialogflow.agents.list
dialogflow.answerrecords.list
dialogflow.callMatchers.list
dialogflow.changelogs.list
dialogflow.contexts.list
dialogflow.conversationDatasets.list
dialogflow.conversationModels.list
dialogflow.conversationProfiles.list
dialogflow.conversations.list
dialogflow.documents.list
dialogflow.entityTypes.list
dialogflow.environments.list
dialogflow.flows.list
dialogflow.intents.list
dialogflow.knowledgeBases.list
dialogflow.messages.*
dialogflow.modelEvaluations.list
dialogflow.pages.list
dialogflow.participants.list
dialogflow.phoneNumberOrders.list
dialogflow.phoneNumbers.list
dialogflow.securitySettings.list
dialogflow.sessionEntityTypes.list
dialogflow.smartMessagingEntries.list
dialogflow.transitionRouteGroups.list
dialogflow.versions.list
dialogflow.webhooks.list
dlp.analyzeRiskTemplates.list
dlp.columnDataProfiles.list
dlp.deidentifyTemplates.list
dlp.estimates.list
dlp.inspectFindings.*
dlp.inspectTemplates.list
dlp.jobTriggers.list
dlp.jobs.list
dlp.projectDataProfiles.list
dlp.storedInfoTypes.list
dlp.tableDataProfiles.list
dns.changes.list
dns.dnsKeys.list
dns.managedZoneOperations.list
dns.managedZones.list
dns.policies.getIamPolicy
dns.policies.list
dns.policies.setIamPolicy
dns.resourceRecordSets.list
dns.responsePolicies.list
dns.responsePolicyRules.list
documentai.evaluations.list
documentai.labelerPools.list
documentai.locations.list
documentai.processorTypes.*
documentai.processorVersions.list
documentai.processors.list
domains.locations.list
domains.operations.list
domains.registrations.getIamPolicy
domains.registrations.list
domains.registrations.setIamPolicy
earlyaccesscenter.campaigns.list
earlyaccesscenter.customerAllowlists.list
earthengine.assets.getIamPolicy
earthengine.assets.list
earthengine.assets.setIamPolicy
earthengine.operations.list
errorreporting.applications.*
errorreporting.errorEvents.list
errorreporting.groups.*
essentialcontacts.contacts.list
eventarc.locations.list
eventarc.operations.list
eventarc.triggers.getIamPolicy
eventarc.triggers.list
eventarc.triggers.setIamPolicy
fcmdata.*
file.backups.list
file.instances.list
file.locations.list
file.operations.list
firebase.clients.list
firebase.links.list
firebase.playLinks.list
firebaseabt.experiments.list
firebaseappdistro.groups.list
firebaseappdistro.releases.list
firebaseappdistro.testers.list
firebasecrashlytics.issues.list
firebasedatabase.instances.list
firebasedynamiclinks.destinations.list
firebasedynamiclinks.domains.list
firebasedynamiclinks.links.list
firebaseextensions.configs.list
firebasehosting.sites.list
firebaseinappmessaging.campaigns.list
firebaseml.compressionjobs.list
firebaseml.models.list
firebaseml.modelversions.list
firebasenotifications.messages.list
firebasepredictions.predictions.list
firebaserules.releases.list
firebaserules.rulesets.list
firebasestorage.buckets.list
fleetengine.vehicles.list
gameservices.gameServerClusters.list
gameservices.gameServerConfigs.list
gameservices.gameServerDeployments.list
gameservices.locations.list
gameservices.operations.list
gameservices.realms.list
gcp.redisenterprise.com/databases.list
gcp.redisenterprise.com/subscriptions.list
genomics.datasets.getIamPolicy
genomics.datasets.list
genomics.datasets.setIamPolicy
genomics.operations.list
gkehub.features.getIamPolicy
gkehub.features.list
gkehub.features.setIamPolicy
gkehub.gateway.getIamPolicy
gkehub.gateway.setIamPolicy
gkehub.locations.list
gkehub.memberships.getIamPolicy
gkehub.memberships.list
gkehub.memberships.setIamPolicy
gkehub.operations.list
gkemulticloud.awsClusters.list
gkemulticloud.awsNodePools.list
gkemulticloud.azureClients.list
gkemulticloud.azureClusters.list
gkemulticloud.azureNodePools.list
gkemulticloud.operations.list
gsuiteaddons.deployments.list
healthcare.annotationStores.getIamPolicy
healthcare.annotationStores.list
healthcare.annotationStores.setIamPolicy
healthcare.annotations.list
healthcare.attributeDefinitions.list
healthcare.consentArtifacts.list
healthcare.consentStores.getIamPolicy
healthcare.consentStores.list
healthcare.consentStores.setIamPolicy
healthcare.consents.list
healthcare.datasets.getIamPolicy
healthcare.datasets.list
healthcare.datasets.setIamPolicy
healthcare.dicomStores.getIamPolicy
healthcare.dicomStores.list
healthcare.dicomStores.setIamPolicy
healthcare.fhirStores.getIamPolicy
healthcare.fhirStores.list
healthcare.fhirStores.setIamPolicy
healthcare.hl7V2Messages.list
healthcare.hl7V2Stores.getIamPolicy
healthcare.hl7V2Stores.list
healthcare.hl7V2Stores.setIamPolicy
healthcare.locations.list
healthcare.operations.list
healthcare.userDataMappings.list
iam.googleapis.com/workloadIdentityPoolProviders.list
iam.googleapis.com/workloadIdentityPools.list
iam.roles.get
iam.roles.list
iam.serviceAccountKeys.list
iam.serviceAccounts.get
iam.serviceAccounts.getIamPolicy
iam.serviceAccounts.list
iam.serviceAccounts.setIamPolicy
iap.tunnel.*
iap.tunnelInstances.getIamPolicy
iap.tunnelInstances.setIamPolicy
iap.tunnelZones.*
iap.web.getIamPolicy
iap.web.setIamPolicy
iap.webServiceVersions.getIamPolicy
iap.webServiceVersions.setIamPolicy
iap.webServices.getIamPolicy
iap.webServices.setIamPolicy
iap.webTypes.getIamPolicy
iap.webTypes.setIamPolicy
integrations.apigeeAuthConfigs.list
integrations.apigeeCertificates.list
integrations.apigeeExecutions.*
integrations.apigeeIntegrationVers.list
integrations.apigeeIntegrations.list
integrations.apigeeSfdcChannels.list
integrations.apigeeSfdcInstances.list
integrations.apigeeSuspensions.list
integrations.securityAuthConfigs.list
integrations.securityExecutions.list
integrations.securityIntegTempVers.list
integrations.securityIntegrationVers.list
integrations.securityIntegrations.list
lifesciences.operations.list
livestream.channels.list
livestream.events.list
livestream.inputs.list
livestream.locations.list
livestream.operations.list
logging.buckets.list
logging.exclusions.list
logging.locations.list
logging.logEntries.list
logging.logMetrics.list
logging.logServiceIndexes.*
logging.logServices.*
logging.logs.list
logging.notificationRules.list
logging.operations.list
logging.privateLogEntries.*
logging.queries.list
logging.sinks.list
logging.views.list
managedidentities.domains.getIamPolicy
managedidentities.domains.list
managedidentities.domains.setIamPolicy
managedidentities.locations.list
managedidentities.operations.list
managedidentities.peerings.getIamPolicy
managedidentities.peerings.list
managedidentities.peerings.setIamPolicy
managedidentities.sqlintegrations.list
memcache.instances.list
memcache.locations.list
memcache.operations.list
metastore.backups.list
metastore.imports.list
metastore.locations.list
metastore.operations.list
metastore.services.getIamPolicy
metastore.services.list
metastore.services.setIamPolicy
ml.jobs.getIamPolicy
ml.jobs.list
ml.jobs.setIamPolicy
ml.locations.list
ml.models.getIamPolicy
ml.models.list
ml.models.setIamPolicy
ml.operations.list
ml.studies.getIamPolicy
ml.studies.list
ml.studies.setIamPolicy
ml.trials.list
ml.versions.list
monitoring.alertPolicies.list
monitoring.dashboards.list
monitoring.groups.list
monitoring.metricDescriptors.list
monitoring.monitoredResourceDescriptors.list
monitoring.notificationChannelDescriptors.list
monitoring.notificationChannels.list
monitoring.publicWidgets.list
monitoring.services.list
monitoring.slos.list
monitoring.timeSeries.list
monitoring.uptimeCheckConfigs.list
networkconnectivity.hubs.getIamPolicy
networkconnectivity.hubs.list
networkconnectivity.hubs.setIamPolicy
networkconnectivity.locations.list
networkconnectivity.operations.list
networkconnectivity.spokes.getIamPolicy
networkconnectivity.spokes.list
networkconnectivity.spokes.setIamPolicy
networkmanagement.connectivitytests.getIamPolicy
networkmanagement.connectivitytests.list
networkmanagement.connectivitytests.setIamPolicy
networkmanagement.locations.list
networkmanagement.operations.list
networksecurity.authorizationPolicies.getIamPolicy
networksecurity.authorizationPolicies.list
networksecurity.authorizationPolicies.setIamPolicy
networksecurity.clientTlsPolicies.getIamPolicy
networksecurity.clientTlsPolicies.list
networksecurity.clientTlsPolicies.setIamPolicy
networksecurity.locations.list
networksecurity.operations.list
networksecurity.serverTlsPolicies.getIamPolicy
networksecurity.serverTlsPolicies.list
networksecurity.serverTlsPolicies.setIamPolicy
networkservices.endpointConfigSelectors.getIamPolicy
networkservices.endpointConfigSelectors.list
networkservices.endpointConfigSelectors.setIamPolicy
networkservices.endpointPolicies.getIamPolicy
networkservices.endpointPolicies.list
networkservices.endpointPolicies.setIamPolicy
networkservices.httpFilters.getIamPolicy
networkservices.httpFilters.list
networkservices.httpFilters.setIamPolicy
networkservices.httpfilters.getIamPolicy
networkservices.httpfilters.list
networkservices.httpfilters.setIamPolicy
networkservices.locations.list
networkservices.operations.list
notebooks.environments.getIamPolicy
notebooks.environments.list
notebooks.environments.setIamPolicy
notebooks.executions.getIamPolicy
notebooks.executions.list
notebooks.executions.setIamPolicy
notebooks.instances.getIamPolicy
notebooks.instances.list
notebooks.instances.setIamPolicy
notebooks.locations.list
notebooks.operations.list
notebooks.runtimes.getIamPolicy
notebooks.runtimes.list
notebooks.runtimes.setIamPolicy
notebooks.schedules.getIamPolicy
notebooks.schedules.list
notebooks.schedules.setIamPolicy
ondemandscanning.operations.list
opsconfigmonitoring.resourceMetadata.list
orgpolicy.constraints.*
orgpolicy.policies.list
osconfig.guestPolicies.list
osconfig.instanceOSPoliciesCompliances.list
osconfig.inventories.list
osconfig.osPolicyAssignmentReports.list
osconfig.osPolicyAssignments.list
osconfig.patchDeployments.list
osconfig.patchJobs.list
osconfig.vulnerabilityReports.list
paymentsresellersubscription.products.*
paymentsresellersubscription.promotions.*
policysimulator.*
privateca.caPools.getIamPolicy
privateca.caPools.list
privateca.caPools.setIamPolicy
privateca.certificateAuthorities.getIamPolicy
privateca.certificateAuthorities.list
privateca.certificateAuthorities.setIamPolicy
privateca.certificateRevocationLists.getIamPolicy
privateca.certificateRevocationLists.list
privateca.certificateRevocationLists.setIamPolicy
privateca.certificateTemplates.getIamPolicy
privateca.certificateTemplates.list
privateca.certificateTemplates.setIamPolicy
privateca.certificates.getIamPolicy
privateca.certificates.list
privateca.certificates.setIamPolicy
privateca.locations.list
privateca.operations.list
privateca.reusableConfigs.getIamPolicy
privateca.reusableConfigs.list
privateca.reusableConfigs.setIamPolicy
proximitybeacon.attachments.list
proximitybeacon.beacons.getIamPolicy
proximitybeacon.beacons.list
proximitybeacon.beacons.setIamPolicy
proximitybeacon.namespaces.getIamPolicy
proximitybeacon.namespaces.list
proximitybeacon.namespaces.setIamPolicy
pubsub.schemas.getIamPolicy
pubsub.schemas.list
pubsub.schemas.setIamPolicy
pubsub.snapshots.getIamPolicy
pubsub.snapshots.list
pubsub.snapshots.setIamPolicy
pubsub.subscriptions.getIamPolicy
pubsub.subscriptions.list
pubsub.subscriptions.setIamPolicy
pubsub.topics.getIamPolicy
pubsub.topics.list
pubsub.topics.setIamPolicy
pubsublite.operations.list
pubsublite.reservations.list
pubsublite.subscriptions.list
pubsublite.topics.list
recaptchaenterprise.keys.list
recaptchaenterprise.relatedaccountgroupmemberships.*
recaptchaenterprise.relatedaccountgroups.*
recommender.bigqueryCapacityCommitmentsInsights.list
recommender.bigqueryCapacityCommitmentsRecommendations.list
recommender.cloudAssetInsights.list
recommender.cloudsqlIdleInstanceRecommendations.list
recommender.cloudsqlInstanceActivityInsights.list
recommender.cloudsqlInstanceCpuUsageInsights.list
recommender.cloudsqlInstanceDiskUsageTrendInsights.list
recommender.cloudsqlInstanceMemoryUsageInsights.list
recommender.cloudsqlInstanceOutOfDiskRecommendations.list
recommender.cloudsqlOverprovisionedInstanceRecommendations.list
recommender.commitmentUtilizationInsights.list
recommender.computeAddressIdleResourceInsights.list
recommender.computeAddressIdleResourceRecommendations.list
recommender.computeDiskIdleResourceInsights.list
recommender.computeDiskIdleResourceRecommendations.list
recommender.computeFirewallInsights.list
recommender.computeImageIdleResourceInsights.list
recommender.computeImageIdleResourceRecommendations.list
recommender.computeInstanceGroupManagerMachineTypeRecommendations.list
recommender.computeInstanceIdleResourceRecommendations.list
recommender.computeInstanceMachineTypeRecommendations.list
recommender.iamPolicyInsights.list
recommender.iamPolicyLateralMovementInsights.list
recommender.iamPolicyRecommendations.list
recommender.iamServiceAccountInsights.list
recommender.locations.list
recommender.loggingProductSuggestionContainerInsights.list
recommender.loggingProductSuggestionContainerRecommendations.list
recommender.monitoringProductSuggestionComputeInsights.list
recommender.monitoringProductSuggestionComputeRecommendations.list
recommender.resourcemanagerProjectUtilizationInsights.list
recommender.resourcemanagerProjectUtilizationRecommendations.list
recommender.usageCommitmentRecommendations.list
redis.instances.list
redis.locations.list
redis.operations.list
remotebuildexecution.instances.list
remotebuildexecution.workerpools.list
resourcemanager.folders.getIamPolicy
resourcemanager.folders.list
resourcemanager.folders.setIamPolicy
resourcemanager.hierarchyNodes.listTagBindings
resourcemanager.organizations.getIamPolicy
resourcemanager.organizations.setIamPolicy
resourcemanager.projects.getIamPolicy
resourcemanager.projects.list
resourcemanager.projects.setIamPolicy
resourcemanager.tagKeys.getIamPolicy
resourcemanager.tagKeys.list
resourcemanager.tagKeys.setIamPolicy
resourcemanager.tagValues.getIamPolicy
resourcemanager.tagValues.list
resourcemanager.tagValues.setIamPolicy
resourcesettings.settings.list
retail.catalogs.list
retail.operations.list
retail.products.list
riskmanager.operations.list
riskmanager.policies.list
riskmanager.reports.list
run.configurations.list
run.locations.*
run.revisions.list
run.routes.list
run.services.getIamPolicy
run.services.list
run.services.setIamPolicy
runtimeconfig.configs.getIamPolicy
runtimeconfig.configs.list
runtimeconfig.configs.setIamPolicy
runtimeconfig.operations.list
runtimeconfig.variables.getIamPolicy
runtimeconfig.variables.list
runtimeconfig.variables.setIamPolicy
runtimeconfig.waiters.getIamPolicy
runtimeconfig.waiters.list
runtimeconfig.waiters.setIamPolicy
secretmanager.locations.list
secretmanager.secrets.getIamPolicy
secretmanager.secrets.list
secretmanager.secrets.setIamPolicy
secretmanager.versions.list
securitycenter.assets.list
securitycenter.findings.list
securitycenter.notificationconfig.list
securitycenter.sources.getIamPolicy
securitycenter.sources.list
securitycenter.sources.setIamPolicy
servicebroker.bindingoperations.list
servicebroker.bindings.getIamPolicy
servicebroker.bindings.list
servicebroker.bindings.setIamPolicy
servicebroker.catalogs.getIamPolicy
servicebroker.catalogs.list
servicebroker.catalogs.setIamPolicy
servicebroker.instanceoperations.list
servicebroker.instances.getIamPolicy
servicebroker.instances.list
servicebroker.instances.setIamPolicy
serviceconsumermanagement.tenancyu.list
servicedirectory.endpoints.getIamPolicy
servicedirectory.endpoints.list
servicedirectory.endpoints.setIamPolicy
servicedirectory.locations.list
servicedirectory.namespaces.getIamPolicy
servicedirectory.namespaces.list
servicedirectory.namespaces.setIamPolicy
servicedirectory.services.getIamPolicy
servicedirectory.services.list
servicedirectory.services.setIamPolicy
servicemanagement.services.getIamPolicy
servicemanagement.services.list
servicemanagement.services.setIamPolicy
servicenetworking.operations.list
serviceusage.operations.list
serviceusage.services.list
source.repos.getIamPolicy
source.repos.list
source.repos.setIamPolicy
spanner.backupOperations.list
spanner.backups.getIamPolicy
spanner.backups.list
spanner.backups.setIamPolicy
spanner.databaseOperations.list
spanner.databases.getIamPolicy
spanner.databases.list
spanner.databases.setIamPolicy
spanner.instanceConfigs.list
spanner.instanceOperations.list
spanner.instances.getIamPolicy
spanner.instances.list
spanner.instances.setIamPolicy
spanner.sessions.list
speech.customClasses.list
speech.phraseSets.list
storage.buckets.getIamPolicy
storage.buckets.list
storage.buckets.setIamPolicy
storage.hmacKeys.list
storage.multipartUploads.list
storage.objects.getIamPolicy
storage.objects.list
storage.objects.setIamPolicy
storagetransfer.agentpools.list
storagetransfer.jobs.list
storagetransfer.operations.list
tpu.acceleratortypes.list
tpu.locations.list
tpu.nodes.list
tpu.operations.list
tpu.tensorflowversions.list
transcoder.jobTemplates.list
transcoder.jobs.list
translationhub.portals.list
visualinspection.annotationSets.list
visualinspection.annotationSpecs.list
visualinspection.annotations.list
visualinspection.datasets.list
visualinspection.images.list
visualinspection.locations.list
visualinspection.modelEvaluations.list
visualinspection.models.list
visualinspection.modules.list
visualinspection.operations.list
visualinspection.solutionArtifacts.list
visualinspection.solutions.list
vmmigration.cloneJobs.list
vmmigration.cutoverJobs.list
vmmigration.datacenterConnectors.list
vmmigration.deployments.list
vmmigration.groups.list
vmmigration.locations.list
vmmigration.migratingVms.list
vmmigration.operations.list
vmmigration.sources.list
vmmigration.targets.list
vmmigration.utilizationReports.list
vpcaccess.connectors.list
vpcaccess.locations.*
vpcaccess.operations.list
workflows.executions.list
workflows.locations.list
workflows.operations.list
workflows.workflows.getIamPolicy
workflows.workflows.list
workflows.workflows.setIamPolicy

*****/

module "security_admin_role" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level = "org"
  target_id    = var.org_id
  role_id      = "AmexSecurityAdmin"
  title        = "custom security admin role"
  description  = "Security admin role, with permissions to get and set any IAM policy"
  base_roles   = ["roles/iam.securityAdmin"]
  members      = ["serviceAccount:${google_service_account.org_terraform.email}"]
  permissions  = []
}

/*###################################
  Custom Role AmexServiceAccountAdmin
*/###################################

/***** AmexServiceAccountAdmin Permissions

  - "iam.serviceAccounts.create",
  - "iam.serviceAccounts.delete",
  - "iam.serviceAccounts.disable",
  - "iam.serviceAccounts.enable",
  - "iam.serviceAccounts.get",
  - "iam.serviceAccounts.getIamPolicy",
  - "iam.serviceAccounts.list",
  - "iam.serviceAccounts.setIamPolicy",
  - "iam.serviceAccounts.undelete",
  - "iam.serviceAccounts.update",
  - "resourcemanager.projects.get",
  - "resourcemanager.projects.list"

*****/

module "service_account_admin_role" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level = "org"
  target_id    = var.org_id
  role_id      = "AmexServiceAccountAdmin"
  title        = "custom service account admin role"
  description  = "Create and manage service accounts"
  base_roles   = ["roles/iam.serviceAccountAdmin"]
  members      = ["serviceAccount:${google_service_account.org_terraform.email}"]
  permissions  = []
}

/*#############################
  Custom Role AmexFolderAdmin
*/#############################

/***** AmexFolderAdmin Permissions

  - "orgpolicy.constraints.list",
  - "orgpolicy.policies.list",
  - "orgpolicy.policy.get",
  - "resourcemanager.folders.create",
  - "resourcemanager.folders.delete",
  - "resourcemanager.folders.get",
  - "resourcemanager.folders.getIamPolicy",
  - "resourcemanager.folders.list",
  - "resourcemanager.folders.move",
  - "resourcemanager.folders.setIamPolicy",
  - "resourcemanager.folders.undelete",
  - "resourcemanager.folders.update",
  - "resourcemanager.projects.get",
  - "resourcemanager.projects.getIamPolicy",
  - "resourcemanager.projects.list",
  - "resourcemanager.projects.move",
  - "resourcemanager.projects.setIamPolicy"

*****/

module "folder_admin_role" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level = "org"
  target_id    = var.org_id
  role_id      = "AmexFolderAdmin"
  title        = "custom folder admin role"
  description  = "Provides all available permissions for working with folders"
  base_roles   = ["roles/resourcemanager.folderAdmin"]
  members      = ["serviceAccount:${google_service_account.org_terraform.email}"]
  permissions  = []
}

/*##################################
  Custom Role AmexOrganizationViewer
*/##################################

/***** AmexOrganizationViewer Permissions

  - "resourcemanager.organizations.get"

*****/

module "organization_viewer_role" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level = "org"
  target_id    = var.org_id
  role_id      = "AmexOrganizationViewer"
  title        = "custom organization viewer role"
  description  = "Provides access to view an organization"
  base_roles   = ["roles/resourcemanager.organizationViewer"]
  members      = ["serviceAccount:${google_service_account.org_terraform.email}"]
  permissions  = []
}

/*############################
  Custom Role AmexPolicyAdmin
*/############################

/***** AmexPolicyAdmin Permissions

  - "orgpolicy.constraints.list",
  - "orgpolicy.policies.list",
  - "orgpolicy.policy.get"

*****/

module "policy_admin_role" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level = "org"
  target_id    = var.org_id
  role_id      = "AmexPolicyAdmin"
  title        = "custom policy_admin role"
  description  = "Full access to policies, access levels, and access zones"
  base_roles   = ["roles/orgpolicy.policyAdmin"]
  members      = ["serviceAccount:${google_service_account.org_terraform.email}"]
  permissions  = []
}

/*#################################
  Custom Role AmexOrganizationAdmin
*/#################################

/***** AmexOrganizationAdmin Permissions

  - "orgpolicy.constraints.list",
  - "orgpolicy.policies.list",
  - "orgpolicy.policy.get",
  - "resourcemanager.folders.get",
  - "resourcemanager.folders.getIamPolicy",
  - "resourcemanager.folders.list",
  - "resourcemanager.folders.setIamPolicy",
  - "resourcemanager.organizations.get",
  - "resourcemanager.organizations.getIamPolicy",
  - "resourcemanager.organizations.setIamPolicy",
  - "resourcemanager.projects.get",
  - "resourcemanager.projects.getIamPolicy",
  - "resourcemanager.projects.list",
  - "resourcemanager.projects.setIamPolicy"

*****/

module "organization_admin_role" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level = "org"
  target_id    = var.org_id
  role_id      = "AmexOrganizationAdmin"
  title        = "custom organization admin role"
  description  = "Access to administer all resources belonging to the organization"
  base_roles   = ["roles/resourcemanager.organizationAdmin"]
  members      = []
  permissions  = []
}


/******************************************
  Create IaC Project
*******************************************/

module "seed_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 10.1.1"
  name                        = "${var.organization}-${var.geo}-${var.env}-seed-${random_id.suffix.hex}"
  disable_services_on_destroy = false
  folder_id                   = google_folder.bootstrap.id
  org_id                      = var.org_id
  billing_account             = var.billing_account
  activate_apis               = var.activate_apis
  labels                      = local.labels
  create_project_sa           = false
}

/******************************************
  Service Account - Terraform for Org
*******************************************/

resource "google_service_account" "org_terraform" {
  project      = module.seed_project.project_id
  account_id   = "org-terraform"
  display_name = "CFT Organization Terraform Account"
}