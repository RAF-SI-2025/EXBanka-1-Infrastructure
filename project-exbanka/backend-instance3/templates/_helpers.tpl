{{- define "exbanka-backend.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "exbanka-backend.podSecurityContext" -}}
securityContext:
  seccompProfile:
    type: RuntimeDefault
{{- end }}

{{- define "exbanka-backend.containerSecurityContext" -}}
securityContext:
  allowPrivilegeEscalation: false
{{- end }}

{{- define "exbanka-backend.rolloutAnnotation" -}}
{{- if .Values.global.forceRollout }}
rollout/restartedAt: {{ .Values.global.forceRollout | quote }}
{{- end }}
{{- end }}
