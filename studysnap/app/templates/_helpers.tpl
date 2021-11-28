{{/*
Create a default fully qualified app name for studysnap.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "studysnap.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Creates an app string for the authentication app (service)
*/}}
{{- define "studysnap.authentication.fullname" -}}
{{- printf "%s-%s" include "studysnap.fullname" . "auth" }}
{{- end }}

{{/*
Creates an app string for the neptune app (service)
*/}}
{{- define "studysnap.neptune.fullname" -}}
{{- printf "%s-%s" include "studysnap.fullname" . "neptune" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "studysnap.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "studysnap.labels" -}}
helm.sh/chart: {{ include "studysnap.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
release: {{ .Release.Name }}
{{- end }}

{{/*
Get the DNS hostname for the postgres database instance
*/}}
{{- define "ssdb.hostname" -}}
{{- printf "%s.%s.svc.cluster.local" .Values.postgresql.fullnameOverride .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Get the DNS hostname for the el-fulltextsearch instance
*/}}
{{- define "elasticsearch.hostname" -}}
{{- printf "elasticsearch-master.%s.svc.cluster.local" .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}