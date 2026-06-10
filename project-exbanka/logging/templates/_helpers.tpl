{{- define "exbanka-logging.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "exbanka-logging.podSecurityContext" -}}
securityContext:
  seccompProfile:
    type: RuntimeDefault
{{- end }}

{{- define "exbanka-logging.containerSecurityContext" -}}
securityContext:
  allowPrivilegeEscalation: false
{{- end }}
