{{- define "workflow-image-registry" }}
{{- with .Values.builder.workflow.docker }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":%s,\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username (.password | quote) .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}

{{- define "kinto.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kinto.fullname" -}}
{{- printf "kintohub" -}}
{{- end -}}

{{- define "kinto.common.fullname" -}}
{{- printf "%s-common" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kinto.core.fullname" -}}
{{- printf "%s-core" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kinto.builder.fullname" -}}
{{- printf "%s-builder" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kinto.frontend.fullname" -}}
{{- printf "%s-frontend" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kinto.workflow.fullname" -}}
{{- printf "%s-builder-workflow" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}