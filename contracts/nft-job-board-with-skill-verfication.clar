;; Job Board with Skill Verification
;; A simple contract for posting jobs and verifying skills

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-data (err u101))
(define-constant err-unauthorized (err u102))

;; Data maps
(define-map jobs uint { employer: principal, title: (string-ascii 50), required-skill: (string-ascii 30) })
(define-map verified-skills { user: principal, skill: (string-ascii 30) } bool)

;; Job ID counter
(define-data-var job-counter uint u0)

;; Function 1: Post a job
(define-public (post-job (title (string-ascii 50)) (required-skill (string-ascii 30)))
  (begin
    (asserts! (and (> (len title) u0) (> (len required-skill) u0)) err-invalid-data)
    (let ((new-id (+ (var-get job-counter) u1)))
      (map-set jobs new-id { employer: tx-sender, title: title, required-skill: required-skill })
      (var-set job-counter new-id)
      (ok { job-id: new-id, title: title, skill: required-skill })
    )
  )
)

;; Function 2: Verify a skill for a user
(define-public (verify-skill (user principal) (skill (string-ascii 30)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set verified-skills { user: user, skill: skill } true)
    (ok { user: user, skill: skill, verified: true })
  )
)

;; Read-only: Get a job by ID
(define-read-only (get-job (job-id uint))
  (ok (map-get? jobs job-id))
)

;; Read-only: Check if a skill is verified
(define-read-only (is-skill-verified (user principal) (skill (string-ascii 30)))
  (ok (default-to false (map-get? verified-skills { user: user, skill: skill })))
)

