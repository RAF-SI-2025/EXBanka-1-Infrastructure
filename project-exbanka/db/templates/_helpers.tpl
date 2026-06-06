{{- define "exbanka-db.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "exbanka-db.podSecurityContext" -}}
securityContext:
  seccompProfile:
    type: RuntimeDefault
{{- end }}

{{- define "exbanka-db.containerSecurityContext" -}}
securityContext:
  allowPrivilegeEscalation: false
{{- end }}
