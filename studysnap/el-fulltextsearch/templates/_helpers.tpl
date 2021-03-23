{{/*
Expand the name of the chart.
*/}}
{{- define "el-fulltextsearch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "el-fulltextsearch.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
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
{{- define "el-fulltextsearch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "el-fulltextsearch.labels" -}}
helm.sh/chart: {{ include "el-fulltextsearch.chart" . }}
{{ include "el-fulltextsearch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "el-fulltextsearch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "el-fulltextsearch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "el-fulltextsearch.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "el-fulltextsearch.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the host DNS name for the notes postgres database instance
*/}}
{{- define "postgresql.fullname" -}}
{{- printf "%s-notedb.%s.svc.cluster.local" .Values.namespace .Values.namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the host DNS name for the notes elasticsearch index
*/}}
{{- define "elasticsearch.fullname" -}}
{{- printf "%s-elasticsearch.%s.svc.cluster.local" .Values.defaultNamespace .Values.defaultNamespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}