
{{/*
Expand the name of the chart.
*/}}
{{- define "metastore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metastore.fullname" -}}
{{- if .Values.fullNameOverride }}
{{- .Values.fullNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "metastore.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "metastore.selectorLabels" -}}
app.kubernetes.io/name: {{ include "metastore.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "metastore.labels" -}}
helm.sh/chart: {{ include "metastore.chart" . }}
{{ include "metastore.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Create the name of the deployment
*/}}
{{- define "metastore.deploymentName" -}}
{{- default (printf "%s" (include "metastore.fullname" .)) .Values.deploymentName }}
{{- end }}

{{/*
Create the name of the job
*/}}
{{- define "metastore.jobName" -}}
{{- default (printf "%s" (include "metastore.fullname" .)) .Values.jobName }}
{{- end }}

{{/*
Create the name of the service
*/}}
{{- define "metastore.serviceName" -}}
{{- default (printf "%s" (include "metastore.fullname" .)) .Values.serviceName }}
{{- end }}

{{/*
Create the name of the network policy
*/}}
{{- define "metastore.networkPolicyName" -}}
{{- default (printf "%s" (include "metastore.fullname" .)) .Values.networkPolicyName }}
{{- end }}

{{/*
Create the name of the hpa
*/}}
{{- define "metastore.hpa" -}}
{{- default (printf "%s" (include "metastore.fullname" .)) .Values.hpaName }}
{{- end }}

{{/*
Create the name of the service account
*/}}
{{- define "metastore.serviceAccount" -}}
{{- default (printf "%s" (include "metastore.fullname" .)) .Values.serviceAccount.name }}
{{- end }}

{{/*
 Override db.user.name by HIVEMS_USER if it exists in extraEnvRaw
*/}}
{{- define "metastore.hasHiveMsUserEnv" -}}
{{- $found := false }}
{{- range .Values.extraEnvRaw }}
  {{- if and (hasKey . "name") (eq .name "HIVEMS_USER") }}
    {{- $found = true }}
  {{- end }}
{{- end }}
{{- $found }}
{{- end }}