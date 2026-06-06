{{- define "exbanka-backend.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
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
