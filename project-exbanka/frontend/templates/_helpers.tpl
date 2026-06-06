{{- define "exbanka-frontend.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "exbanka-frontend.podSecurityContext" -}}
securityContext:
  seccompProfile:
    type: RuntimeDefault
{{- end }}

{{- define "exbanka-frontend.containerSecurityContext" -}}
securityContext:
  allowPrivilegeEscalation: false
{{- end }}

{{- define "exbanka-frontend.rolloutAnnotation" -}}
{{- if .Values.global.forceRollout }}
rollout/restartedAt: {{ .Values.global.forceRollout | quote }}
{{- end }}
{{- end }}

{{- define "exbanka-frontend.keelAnnotations" -}}
keel.sh/policy: {{ .Values.keel.policy | quote }}
keel.sh/trigger: {{ .Values.keel.trigger | quote }}
keel.sh/pollSchedule: {{ .Values.keel.pollSchedule | quote }}
keel.sh/match-tag: {{ .Values.keel.matchTag | quote }}
{{- end }}
