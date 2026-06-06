{{- define "exbanka-infrastructure.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "exbanka-infrastructure.podSecurityContext" -}}
securityContext:
  seccompProfile:
    type: RuntimeDefault
{{- end }}

{{- define "exbanka-infrastructure.containerSecurityContext" -}}
securityContext:
  allowPrivilegeEscalation: false
{{- end }}
