<!--
    Copyright 2024 okdp.io

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
-->

# hive-metastore

## Introduction

This chart bootstraps a [Hive Metastore](https://cwiki.apache.org/confluence/display/hive/design#Design-Metastore) deployment using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Helm >= 3
- Kubernetes >= 1.19

## Installing the chart

To install the chart with the release name `my-release`:

```shell
$ helm install my-release oci://quay.io/okdp/charts/hive-metastore --version 3.1.3-1.3.1
```

This will create a release of `my-release` in the default namespace. To install in a different namespace:

```shell
$ helm install my-release oci://quay.io/okdp/charts/hive-metastore --version 3.1.3-1.3.1 \
       --namespace hive-metastore
```

Note that `helm` will fail to install if the namespace doesn't exist. Either create the namespace beforehand or pass the `--create-namespace` flag to the `helm install` command.

## Uninstalling the chart  `my-release`

To uninstall `my-release`:

```shell
$ helm uninstall my-release -n hive-metastore
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Downloading the chart locally

To download the chart locally, use the following command:

```shell
$ helm pull oci://quay.io/okdp/charts/hive-metastore --version 3.1.3-1.3.1
```

## Values

<table height="100%" >
	<thead>
		<th>Key</th>
		<th>Type</th>
		<th>Default</th>
		<th>Description</th>
	</thead>
	<tbody>
		<tr>
			<td id="affinity"><a href="./values.yaml#L290">affinity</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div></td>
			<td>Affinity for the hive-metastore pod.</td>
		</tr>
		<tr>
			<td id="autoscaling"><a href="./values.yaml#L214">autoscaling</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{
  "enabled": false,
  "maxReplicas": 3,
  "minReplicas": 1,
  "targetCPUUtilizationPercentage": null,
  "targetMemoryUtilizationPercentage": null
}
</pre>
</div></td>
			<td>Enable autoscaling for the hive-metastore component. Disable 'autoscaling' when using the replicaCount parameter.</td>
		</tr>
		<tr>
			<td id="aws--podIamRole"><a href="./values.yaml#L60">aws.podIamRole</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>AWS Pod execution IAM role.</td>
		</tr>
		<tr>
			<td id="aws--s3AssumeRoleArn"><a href="./values.yaml#L62">aws.s3AssumeRoleArn</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>S3 IAM role ARN for hive-metastore access to S3.</td>
		</tr>
		<tr>
			<td id="cloud_storage"><a href="./values.yaml#L46">cloud_storage</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
"s3"
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="commonAnnotations"><a href="./values.yaml#L299">commonAnnotations</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div></td>
			<td>Annotations to be added to all resources.</td>
		</tr>
		<tr>
			<td id="configOverrides"><a href="./values.yaml#L77">configOverrides</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div></td>
			<td>Configuration overrides, with env variables support, that will be passed into pods on /etc/hadoop/conf and /etc/hive/conf.</td>
		</tr>
		<tr>
			<td id="containerSecurityContext--allowPrivilegeEscalation"><a href="./values.yaml#L279">containerSecurityContext.allowPrivilegeEscalation</a></td>
			<td>
bool
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="containerSecurityContext--capabilities--drop[0]"><a href="./values.yaml#L283">containerSecurityContext.capabilities.drop[0]</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
"ALL"
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="containerSecurityContext--readOnlyRootFilesystem"><a href="./values.yaml#L280">containerSecurityContext.readOnlyRootFilesystem</a></td>
			<td>
bool
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="db--databaseName"><a href="./values.yaml#L12">db.databaseName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
"hms"
</pre>
</div></td>
			<td>Hive metastore database name.</td>
		</tr>
		<tr>
			<td id="db--driverName"><a href="./values.yaml#L6">db.driverName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
"postgresql"
</pre>
</div></td>
			<td>Hive metastore driver name.  One of `` `postgresql` or `mysql`</td>
		</tr>
		<tr>
			<td id="db--driverRef"><a href="./values.yaml#L4">db.driverRef</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
"org.postgresql.Driver"
</pre>
</div></td>
			<td>Hive metastore driver reference.</td>
		</tr>
		<tr>
			<td id="db--host"><a href="./values.yaml#L8">db.host</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>Hive metastore database host.</td>
		</tr>
		<tr>
			<td id="db--port"><a href="./values.yaml#L10">db.port</a></td>
			<td>
int
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
5432
</pre>
</div></td>
			<td>Hive metastore database port.</td>
		</tr>
		<tr>
			<td id="db--user--name"><a href="./values.yaml#L15">db.user.name</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
"hms"
</pre>
</div></td>
			<td>Hive metastore database user.</td>
		</tr>
		<tr>
			<td id="db--user--password--propertyName"><a href="./values.yaml#L21">db.user.password.propertyName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>Hive metastore database existing kubernetes secret key containing the password.</td>
		</tr>
		<tr>
			<td id="db--user--password--secretName"><a href="./values.yaml#L19">db.user.password.secretName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>Hive metastore database existing kubernetes secret name.</td>
		</tr>
		<tr>
			<td id="deploymentName"><a href="./values.yaml#L309">deploymentName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>Will default to {{ include "metastore.fullname" . }}</td>
		</tr>
		<tr>
			<td id="exposure"><a href="./values.yaml#L241">exposure</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{
  "loadbalancer": {
    "metallb": {
      "enabled": "no",
      "externalIp": null,
      "ipSharingKey": null
    }
  },
  "nodePort": {
    "enabled": "no",
    "value": null
  }
}
</pre>
</div></td>
			<td>Allow the metastore to be reachable from outside of the cluster

⚠️ As the metastore does not provide authentication/authorization mechanism, everybody will be able
  to access and modify all metastore data.
  So use this feature only
  - Temporary, for test and debugging
  - If access to your cluster is strictly controlled by some firewall, which will limit access to the
    exposed address and port.
</td>
		</tr>
		<tr>
			<td id="extraEnvRaw"><a href="./values.yaml#L65">extraEnvRaw</a></td>
			<td>
list
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div></td>
			<td>Extra environment variables in RAW format that will be passed into pods</td>
		</tr>
		<tr>
			<td id="fullNameOverride"><a href="./values.yaml#L307">fullNameOverride</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>Allow overriding base name of all resources.</td>
		</tr>
		<tr>
			<td id="gcs--enabled"><a href="./values.yaml#L50">gcs.enabled</a></td>
			<td>
bool
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="gcs--projectId"><a href="./values.yaml#L51">gcs.projectId</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="gcs--serviceAccountKeyFile"><a href="./values.yaml#L56">gcs.serviceAccountKeyFile</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="gcs--warehouseDirectory"><a href="./values.yaml#L52">gcs.warehouseDirectory</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="gcs--workloadIdentity--enabled"><a href="./values.yaml#L54">gcs.workloadIdentity.enabled</a></td>
			<td>
bool
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="gcs--workloadIdentity--gcpServiceAccount"><a href="./values.yaml#L55">gcs.workloadIdentity.gcpServiceAccount</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="hpaName"><a href="./values.yaml#L317">hpaName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>Will default to {{ include "metastore.fullname" . }}</td>
		</tr>
		<tr>
			<td id="image--pullPolicy"><a href="./values.yaml#L262">image.pullPolicy</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
"IfNotPresent"
</pre>
</div></td>
			<td>Image pull policy.</td>
		</tr>
		<tr>
			<td id="image--pullSecrets"><a href="./values.yaml#L255">image.pullSecrets</a></td>
			<td>
list
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
[
  {
    "name": "data"
  }
]
</pre>
</div></td>
			<td>Image pullSecrets for private registries.</td>
		</tr>
		<tr>
			<td id="image--repository"><a href="./values.yaml#L258">image.repository</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
"quay.io/okdp/hive-metastore"
</pre>
</div></td>
			<td>Docker image registry.</td>
		</tr>
		<tr>
			<td id="image--tag"><a href="./values.yaml#L260">image.tag</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
"latest"
</pre>
</div></td>
			<td>Image tag.</td>
		</tr>
		<tr>
			<td id="initJob"><a href="./values.yaml#L225">initJob</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{
  "annotations": {
    "helm.sh/hook": "post-install,post-upgrade",
    "helm.sh/hook-delete-policy": "before-hook-creation"
  },
  "ttlSecondsAfterFinished": 60
}
</pre>
</div></td>
			<td>Hive metastore database initialization job</td>
		</tr>
		<tr>
			<td id="jobName"><a href="./values.yaml#L311">jobName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>Will default to {{ include "metastore.fullname" . }}</td>
		</tr>
		<tr>
			<td id="logLevel"><a href="./values.yaml#L222">logLevel</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
"INFO"
</pre>
</div></td>
			<td>Log4j2 log level. One of `` `debug`, `info`, `warn`, `error`, `fatal`, `trace`</td>
		</tr>
		<tr>
			<td id="nameOverride"><a href="./values.yaml#L305">nameOverride</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>Allow chart name overriding.</td>
		</tr>
		<tr>
			<td id="networkPolicies--allowedNamespace"><a href="./values.yaml#L199">networkPolicies.allowedNamespace</a></td>
			<td>
list
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="networkPolicies--allowedNamespaceLabels"><a href="./values.yaml#L198">networkPolicies.allowedNamespaceLabels</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="networkPolicies--enabled"><a href="./values.yaml#L197">networkPolicies.enabled</a></td>
			<td>
bool
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="networkPolicyName"><a href="./values.yaml#L315">networkPolicyName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>Will default to {{ include "metastore.fullname" . }}</td>
		</tr>
		<tr>
			<td id="nodeSelector"><a href="./values.yaml#L286">nodeSelector</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div></td>
			<td>Node selector for the hive-metastore pod.</td>
		</tr>
		<tr>
			<td id="podAnnotations"><a href="./values.yaml#L296">podAnnotations</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div></td>
			<td>Annotations to be added to the pod.</td>
		</tr>
		<tr>
			<td id="podSecurityContext"><a href="./values.yaml#L273">podSecurityContext</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{
  "runAsNonRoot": true,
  "seccompProfile": {
    "type": "RuntimeDefault"
  }
}
</pre>
</div></td>
			<td>Security profile for the hive-metastore pod.</td>
		</tr>
		<tr>
			<td id="replicaCount"><a href="./values.yaml#L202">replicaCount</a></td>
			<td>
int
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
2
</pre>
</div></td>
			<td>Desired number of hive-metastore pods to run. Set 'replicaCount' to 0 or leave it unused when autoscaling is enabled.</td>
		</tr>
		<tr>
			<td id="resources"><a href="./values.yaml#L205">resources</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{
  "limits": {
    "cpu": "500m",
    "memory": "1024Mi"
  },
  "requests": {
    "cpu": "100m",
    "memory": "512Mi"
  }
}
</pre>
</div></td>
			<td>Resource requests and limits for the hive-metastore pod.</td>
		</tr>
		<tr>
			<td id="s3--accessKey--propertyName"><a href="./values.yaml#L33">s3.accessKey.propertyName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>S3 access key kubernetes secret key containing the accessKey.</td>
		</tr>
		<tr>
			<td id="s3--accessKey--secretName"><a href="./values.yaml#L31">s3.accessKey.secretName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>S3 access key existing kubernetes secret name.</td>
		</tr>
		<tr>
			<td id="s3--proxy"><a href="./values.yaml#L40">s3.proxy</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{
  "host": null,
  "port": null
}
</pre>
</div></td>
			<td>Proxy configuration (if needed).</td>
		</tr>
		<tr>
			<td id="s3--requestTimeout"><a href="./values.yaml#L43">s3.requestTimeout</a></td>
			<td>
int
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
0
</pre>
</div></td>
			<td></td>
		</tr>
		<tr>
			<td id="s3--secretKey--propertyName"><a href="./values.yaml#L38">s3.secretKey.propertyName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>S3 secret key kubernetes secret key containing the secretName.</td>
		</tr>
		<tr>
			<td id="s3--secretKey--secretName"><a href="./values.yaml#L36">s3.secretKey.secretName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>S3 secret key existing kubernetes secret name.</td>
		</tr>
		<tr>
			<td id="s3--url"><a href="./values.yaml#L26">s3.url</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>S3 endpoint</td>
		</tr>
		<tr>
			<td id="s3--warehouseDirectory"><a href="./values.yaml#L28">s3.warehouseDirectory</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>S3 warehouse directory/bucket name.</td>
		</tr>
		<tr>
			<td id="serviceAccount"><a href="./values.yaml#L265">serviceAccount</a></td>
			<td>
object
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
{
  "annotations": {},
  "create": true,
  "name": ""
}
</pre>
</div></td>
			<td>Specifies whether a service account should be created.</td>
		</tr>
		<tr>
			<td id="serviceName"><a href="./values.yaml#L313">serviceName</a></td>
			<td>
string
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div></td>
			<td>Will default to {{ include "metastore.fullname" . }}</td>
		</tr>
		<tr>
			<td id="servicePort"><a href="./values.yaml#L293">servicePort</a></td>
			<td>
int
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
9083
</pre>
</div></td>
			<td>Hive metastore service port.</td>
		</tr>
		<tr>
			<td id="tolerations"><a href="./values.yaml#L288">tolerations</a></td>
			<td>
list
</td>
			<td><div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div></td>
			<td>Tolerations for the hive-metastore pod.</td>
		</tr>
	</tbody>
</table>

## Source Code

* <https://github.com/okdp/hive-metastore>
