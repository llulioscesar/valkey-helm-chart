{{/*
Expand the name of the chart.
*/}}
{{- define "valkey.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "valkey.fullname" -}}
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
{{- define "valkey.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "valkey.labels" -}}
helm.sh/chart: {{ include "valkey.chart" . }}
{{ include "valkey.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "valkey.selectorLabels" -}}
app.kubernetes.io/name: {{ include "valkey.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "valkey.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "valkey.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the Valkey image
*/}}
{{- define "valkey.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
{{- if .Values.global.imageRegistry }}
    {{- $registryName = .Values.global.imageRegistry -}}
{{- end -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end }}

{{/*
Get the metrics image
*/}}
{{- define "valkey.metrics.image" -}}
{{- $registryName := .Values.metrics.image.registry -}}
{{- $repositoryName := .Values.metrics.image.repository -}}
{{- $tag := .Values.metrics.image.tag | toString -}}
{{- if .Values.global.imageRegistry }}
    {{- $registryName = .Values.global.imageRegistry -}}
{{- end -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end }}

{{/*
Get the password secret name
*/}}
{{- define "valkey.secretName" -}}
{{- if .Values.auth.existingSecret -}}
{{- .Values.auth.existingSecret -}}
{{- else -}}
{{- include "valkey.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
Get the password secret key
*/}}
{{- define "valkey.secretPasswordKey" -}}
{{- if .Values.auth.existingSecret -}}
{{- .Values.auth.existingSecretPasswordKey -}}
{{- else -}}
password
{{- end -}}
{{- end }}

{{/*
Standalone labels
*/}}
{{- define "valkey.standalone.labels" -}}
{{ include "valkey.labels" . }}
app.kubernetes.io/component: standalone
{{- end }}

{{/*
Standalone selector labels
*/}}
{{- define "valkey.standalone.selectorLabels" -}}
{{ include "valkey.selectorLabels" . }}
app.kubernetes.io/component: standalone
{{- end }}

{{/*
Master labels
*/}}
{{- define "valkey.master.labels" -}}
{{ include "valkey.labels" . }}
app.kubernetes.io/component: master
{{- end }}

{{/*
Master selector labels
*/}}
{{- define "valkey.master.selectorLabels" -}}
{{ include "valkey.selectorLabels" . }}
app.kubernetes.io/component: master
{{- end }}

{{/*
Replica labels
*/}}
{{- define "valkey.replica.labels" -}}
{{ include "valkey.labels" . }}
app.kubernetes.io/component: replica
{{- end }}

{{/*
Replica selector labels
*/}}
{{- define "valkey.replica.selectorLabels" -}}
{{ include "valkey.selectorLabels" . }}
app.kubernetes.io/component: replica
{{- end }}

{{/*
Sentinel labels
*/}}
{{- define "valkey.sentinel.labels" -}}
{{ include "valkey.labels" . }}
app.kubernetes.io/component: sentinel
{{- end }}

{{/*
Sentinel selector labels
*/}}
{{- define "valkey.sentinel.selectorLabels" -}}
{{ include "valkey.selectorLabels" . }}
app.kubernetes.io/component: sentinel
{{- end }}

{{/*
Generate common annotations
*/}}
{{- define "valkey.annotations" -}}
{{- with .Values.commonAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Validate architecture
*/}}
{{- define "valkey.validateArchitecture" -}}
{{- if not (or (eq .Values.architecture "standalone") (eq .Values.architecture "sentinel")) }}
{{- fail "Architecture must be either 'standalone' or 'sentinel'" }}
{{- end }}
{{- end }}

{{/*
Check if sentinel is enabled
*/}}
{{- define "valkey.sentinel.enabled" -}}
{{- if eq .Values.architecture "sentinel" }}
{{- true }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{/*
Master service name
*/}}
{{- define "valkey.master.serviceName" -}}
{{- if eq .Values.architecture "sentinel" }}
{{- printf "%s-master" (include "valkey.fullname" .) }}
{{- else }}
{{- include "valkey.fullname" . }}
{{- end }}
{{- end }}

{{/*
Replica service name
*/}}
{{- define "valkey.replica.serviceName" -}}
{{- printf "%s-replica" (include "valkey.fullname" .) }}
{{- end }}

{{/*
Sentinel service name
*/}}
{{- define "valkey.sentinel.serviceName" -}}
{{- printf "%s-sentinel" (include "valkey.fullname" .) }}
{{- end }}

{{/*
Get the volume permissions init container image
*/}}
{{- define "valkey.volumePermissions.image" -}}
{{- $registryName := .Values.volumePermissions.image.registry -}}
{{- $repositoryName := .Values.volumePermissions.image.repository -}}
{{- $tag := .Values.volumePermissions.image.tag | toString -}}
{{- if .Values.global.imageRegistry }}
    {{- $registryName = .Values.global.imageRegistry -}}
{{- end -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end }}

{{/*
Return the proper Valkey configuration configmap name
*/}}
{{- define "valkey.configmapName" -}}
{{- if .Values.existingConfigmap -}}
{{- .Values.existingConfigmap -}}
{{- else -}}
{{- include "valkey.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
Return the Valkey configuration
*/}}
{{- define "valkey.configuration" -}}
{{- if eq .Values.architecture "standalone" }}
{{- .Values.standalone.configuration | default "" }}
{{- else if eq .Values.architecture "sentinel" }}
{{- .Values.master.configuration | default "" }}
{{- end }}
{{- end }}

{{/*
Return if Valkey authentication is enabled
*/}}
{{- define "valkey.auth.enabled" -}}
{{- if .Values.auth.enabled -}}
true
{{- end -}}
{{- end }}

{{/*
Return the Valkey port
*/}}
{{- define "valkey.port" -}}
{{- if eq .Values.architecture "standalone" }}
{{- .Values.standalone.service.port | default 6379 }}
{{- else }}
{{- .Values.master.service.port | default 6379 }}
{{- end }}
{{- end }}

{{/*
Return whether NetworkPolicy is enabled
*/}}
{{- define "valkey.networkPolicy.enabled" -}}
{{- if .Values.networkPolicy.enabled }}
{{- true }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{/*
Return true if persistence is enabled
*/}}
{{- define "valkey.persistence.enabled" -}}
{{- if eq .Values.architecture "standalone" }}
{{- .Values.standalone.persistence.enabled }}
{{- else }}
{{- or .Values.master.persistence.enabled .Values.replica.persistence.enabled }}
{{- end }}
{{- end }}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "valkey.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "valkey.validateValues.architecture" .) -}}
{{- $messages := append $messages (include "valkey.validateValues.sentinel" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate values of Valkey - Architecture
*/}}
{{- define "valkey.validateValues.architecture" -}}
{{- if not (or (eq .Values.architecture "standalone") (eq .Values.architecture "sentinel")) -}}
valkey: architecture
    Invalid architecture selected. Valid values are "standalone" and
    "sentinel". Please set a valid architecture (--set architecture="xxxx")
{{- end -}}
{{- end -}}

{{/*
Validate values of Valkey - Sentinel
*/}}
{{- define "valkey.validateValues.sentinel" -}}
{{- if and (eq .Values.architecture "sentinel") (lt (.Values.sentinel.replicaCount | int) 3) -}}
valkey: sentinel.replicaCount
    Sentinel replica count should be at least 3 for high availability.
    Please set a valid number of replicas (--set sentinel.replicaCount=3)
{{- end -}}
{{- end -}}

{{/*
Return the proper Valkey Sentinel image name
*/}}
{{- define "valkey.sentinel.image" -}}
{{- $registryName := .Values.sentinel.image.registry -}}
{{- $repositoryName := .Values.sentinel.image.repository -}}
{{- $tag := .Values.sentinel.image.tag | toString -}}
{{- if .Values.global.imageRegistry }}
    {{- $registryName = .Values.global.imageRegistry -}}
{{- end -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end }}

{{/*
Create the name of the master service account to use
*/}}
{{- define "valkey.master.serviceAccountName" -}}
{{- if .Values.master.serviceAccount.create -}}
    {{ default (printf "%s-master" (include "valkey.fullname" .)) .Values.master.serviceAccount.name }}
{{- else -}}
    {{- if .Values.serviceAccount.create -}}
        {{ template "valkey.serviceAccountName" . }}
    {{- else -}}
        {{ default "default" .Values.master.serviceAccount.name }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the replica service account to use
*/}}
{{- define "valkey.replica.serviceAccountName" -}}
{{- if .Values.replica.serviceAccount.create -}}
    {{ default (printf "%s-replica" (include "valkey.fullname" .)) .Values.replica.serviceAccount.name }}
{{- else -}}
    {{- if .Values.serviceAccount.create -}}
        {{ template "valkey.serviceAccountName" . }}
    {{- else -}}
        {{ default "default" .Values.replica.serviceAccount.name }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the sentinel service account to use
*/}}
{{- define "valkey.sentinel.serviceAccountName" -}}
{{- if .Values.sentinel.serviceAccount.create -}}
    {{ default (printf "%s-sentinel" (include "valkey.fullname" .)) .Values.sentinel.serviceAccount.name }}
{{- else -}}
    {{- if .Values.serviceAccount.create -}}
        {{ template "valkey.serviceAccountName" . }}
    {{- else -}}
        {{ default "default" .Values.sentinel.serviceAccount.name }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created
*/}}
{{- define "valkey.createConfigmap" -}}
{{- if empty .Values.existingConfigmap }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Valkey password
*/}}
{{- define "valkey.password" -}}
{{- if .Values.auth.enabled -}}
    {{- if .Values.auth.password -}}
        {{- .Values.auth.password -}}
    {{- else -}}
        {{- randAlphaNum 10 -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return true if TLS is enabled
*/}}
{{- define "valkey.tls.enabled" -}}
{{- if .Values.tls.enabled -}}
true
{{- end -}}
{{- end }}

{{/*
Return the TLS secret name
*/}}
{{- define "valkey.tls.secretName" -}}
{{- if .Values.tls.existingSecret -}}
    {{- .Values.tls.existingSecret -}}
{{- else -}}
    {{- printf "%s-tls" (include "valkey.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the cert file
*/}}
{{- define "valkey.tls.certFilename" -}}
{{- if .Values.tls.certFilename -}}
    {{- .Values.tls.certFilename -}}
{{- else -}}
    {{- "tls.crt" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the cert key file
*/}}
{{- define "valkey.tls.certKeyFilename" -}}
{{- if .Values.tls.certKeyFilename -}}
    {{- .Values.tls.certKeyFilename -}}
{{- else -}}
    {{- "tls.key" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the CA cert file
*/}}
{{- define "valkey.tls.caCertFilename" -}}
{{- if .Values.tls.caCertFilename -}}
    {{- .Values.tls.caCertFilename -}}
{{- else -}}
    {{- "ca.crt" -}}
{{- end -}}
{{- end -}}

{{/*
Return if metrics are enabled
*/}}
{{- define "valkey.metrics.enabled" -}}
{{- if .Values.metrics.enabled -}}
true
{{- end -}}
{{- end -}}

{{/*
Return the metrics service name
*/}}
{{- define "valkey.metrics.serviceName" -}}
{{- printf "%s-metrics" (include "valkey.fullname" .) -}}
{{- end -}}

{{/*
Return the headless service name
*/}}
{{- define "valkey.headless.serviceName" -}}
{{- printf "%s-headless" (include "valkey.fullname" .) -}}
{{- end -}}

{{/*
Return whether RBAC is enabled
*/}}
{{- define "valkey.rbac.enabled" -}}
{{- if .Values.rbac.create }}
    {{- true -}}
{{- else }}
    {{- false -}}
{{- end }}
{{- end -}}

{{/*
Return whether PodSecurityPolicy is enabled
*/}}
{{- define "valkey.psp.enabled" -}}
{{- if .Values.podSecurityPolicy.enabled }}
    {{- true -}}
{{- else }}
    {{- false -}}
{{- end }}
{{- end -}}

{{/*
Return whether ServiceMonitor is enabled
*/}}
{{- define "valkey.serviceMonitor.enabled" -}}
{{- if and .Values.metrics.enabled .Values.metrics.serviceMonitor.enabled }}
    {{- true -}}
{{- else }}
    {{- false -}}
{{- end }}
{{- end -}}

{{/*
Return whether PodMonitor is enabled
*/}}
{{- define "valkey.podMonitor.enabled" -}}
{{- if and .Values.metrics.enabled .Values.metrics.podMonitor.enabled }}
    {{- true -}}
{{- else }}
    {{- false -}}
{{- end }}
{{- end -}}

{{/*
Return whether PrometheusRule is enabled
*/}}
{{- define "valkey.prometheusRule.enabled" -}}
{{- if and .Values.metrics.enabled .Values.metrics.prometheusRule.enabled }}
    {{- true -}}
{{- else }}
    {{- false -}}
{{- end }}
{{- end -}}

{{/*
Return the appropriate storageClass for master
*/}}
{{- define "valkey.master.storageClass" -}}
{{- if .Values.master.persistence.storageClass -}}
  {{- if (eq "-" .Values.master.persistence.storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" .Values.master.persistence.storageClass -}}
  {{- end -}}
{{- else -}}
  {{- if .Values.global.storageClass -}}
      {{- if (eq "-" .Values.global.storageClass) -}}
          {{- printf "storageClassName: \"\"" -}}
      {{- else }}
          {{- printf "storageClassName: %s" .Values.global.storageClass -}}
      {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate storageClass for replica
*/}}
{{- define "valkey.replica.storageClass" -}}
{{- if .Values.replica.persistence.storageClass -}}
  {{- if (eq "-" .Values.replica.persistence.storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" .Values.replica.persistence.storageClass -}}
  {{- end -}}
{{- else -}}
  {{- if .Values.global.storageClass -}}
      {{- if (eq "-" .Values.global.storageClass) -}}
          {{- printf "storageClassName: \"\"" -}}
      {{- else }}
          {{- printf "storageClassName: %s" .Values.global.storageClass -}}
      {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate storageClass for standalone
*/}}
{{- define "valkey.standalone.storageClass" -}}
{{- if .Values.standalone.persistence.storageClass -}}
  {{- if (eq "-" .Values.standalone.persistence.storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" .Values.standalone.persistence.storageClass -}}
  {{- end -}}
{{- else -}}
  {{- if .Values.global.storageClass -}}
      {{- if (eq "-" .Values.global.storageClass) -}}
          {{- printf "storageClassName: \"\"" -}}
      {{- else }}
          {{- printf "storageClassName: %s" .Values.global.storageClass -}}
      {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}