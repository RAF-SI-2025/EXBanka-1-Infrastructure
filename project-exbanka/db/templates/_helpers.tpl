{{- define "exbanka-db.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
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
