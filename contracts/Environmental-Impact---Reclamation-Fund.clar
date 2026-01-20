(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED u401)
(define-constant ERR_PROJECT_NOT_FOUND u404)
(define-constant ERR_INSUFFICIENT_FUNDS u402)
(define-constant ERR_PROJECT_ALREADY_EXISTS u409)
(define-constant ERR_INVALID_VERIFICATION u400)
(define-constant ERR_FUNDS_ALREADY_RELEASED u403)
(define-constant ERR_PROJECT_NOT_ACTIVE u405)

(define-map projects
    {project-id: uint}
    {
        company: principal,
        deposit-amount: uint,
        verification-required: uint,
        verifications-received: uint,
        status: (string-ascii 20),
        created-at: uint,
        verified-at: (optional uint),
        released-at: (optional uint),
        milestones-count: uint
    }
)

(define-map verifiers principal bool)

(define-map project-verifications
    {project-id: uint, verifier: principal}
    {verified: bool, timestamp: uint}
)

(define-map project-milestones
    {project-id: uint, milestone-id: uint}
    {
        description: (string-ascii 256),
        completed: bool,
        completed-at: (optional uint)
    }
)

(define-data-var next-project-id uint u1)
(define-data-var total-deposits uint u0)
(define-data-var total-released uint u0)
(define-data-var contract-paused bool false)

(define-public (add-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (ok (map-set verifiers verifier true))
    )
)

(define-public (remove-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (ok (map-delete verifiers verifier))
    )
)

(define-public (pause-contract)
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (ok (var-set contract-paused true))
    )
)

(define-public (unpause-contract)
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (ok (var-set contract-paused false))
    )
)

(define-public (create-project (deposit-amount uint) (verification-required uint))
    (let
        (
            (project-id (var-get next-project-id))
            (current-balance (stx-get-balance tx-sender))
        )
        (asserts! (not (var-get contract-paused)) (err ERR_NOT_AUTHORIZED))
        (asserts! (>= current-balance deposit-amount) (err ERR_INSUFFICIENT_FUNDS))
        (asserts! (is-none (map-get? projects {project-id: project-id})) (err ERR_PROJECT_ALREADY_EXISTS))
        (asserts! (> verification-required u0) (err ERR_INVALID_VERIFICATION))
        
        (try! (stx-transfer? deposit-amount tx-sender (as-contract tx-sender)))
        
        (map-set projects
            {project-id: project-id}
            {
                company: tx-sender,
                deposit-amount: deposit-amount,
                verification-required: verification-required,
                verifications-received: u0,
                status: "active",
                created-at: stacks-block-height,
                verified-at: none,
                released-at: none,
                milestones-count: u0
            }
        )
        
        (var-set next-project-id (+ project-id u1))
        (var-set total-deposits (+ (var-get total-deposits) deposit-amount))
        
        (ok project-id)
    )
)

(define-public (verify-restoration (project-id uint))
    (let 
        (
            (project (unwrap! (map-get? projects {project-id: project-id}) (err ERR_PROJECT_NOT_FOUND)))
            (is-verifier (default-to false (map-get? verifiers tx-sender)))
            (already-verified (default-to false (get verified (map-get? project-verifications {project-id: project-id, verifier: tx-sender}))))
        )
        (asserts! is-verifier (err ERR_NOT_AUTHORIZED))
        (asserts! (is-eq (get status project) "active") (err ERR_PROJECT_NOT_ACTIVE))
        (asserts! (not already-verified) (err ERR_INVALID_VERIFICATION))
        
        (let 
            (
                (new-verifications (+ (get verifications-received project) u1))
                (updated-project (merge project {verifications-received: new-verifications}))
            )
            (map-set project-verifications 
                {project-id: project-id, verifier: tx-sender}
                {verified: true, timestamp: stacks-block-height}
            )
            
            (if (>= new-verifications (get verification-required project))
                (begin
                    (map-set projects 
                        {project-id: project-id}
                        (merge updated-project {status: "verified", verified-at: (some stacks-block-height)})
                    )
                    (ok "project-verified")
                )
                (begin
                    (map-set projects {project-id: project-id} updated-project)
                    (ok "verification-recorded")
                )
            )
        )
    )
)

(define-public (release-funds (project-id uint))
    (let
        (
            (project (unwrap! (map-get? projects {project-id: project-id}) (err ERR_PROJECT_NOT_FOUND)))
            (company (get company project))
            (deposit-amount (get deposit-amount project))
        )
        (asserts! (not (var-get contract-paused)) (err ERR_NOT_AUTHORIZED))
        (asserts! (is-eq tx-sender company) (err ERR_NOT_AUTHORIZED))
        (asserts! (is-eq (get status project) "verified") (err ERR_PROJECT_NOT_ACTIVE))
        (asserts! (>= (get verifications-received project) (get verification-required project)) (err ERR_INVALID_VERIFICATION))
        
        (try! (as-contract (stx-transfer? deposit-amount tx-sender company)))
        
        (map-set projects 
            {project-id: project-id}
            (merge project {status: "released", released-at: (some stacks-block-height)})
        )
        
        (var-set total-released (+ (var-get total-released) deposit-amount))
        
        (ok deposit-amount)
    )
)

(define-public (cancel-project (project-id uint))
    (let
        (
            (project (unwrap! (map-get? projects {project-id: project-id}) (err ERR_PROJECT_NOT_FOUND)))
            (company (get company project))
            (deposit-amount (get deposit-amount project))
        )
        (asserts! (is-eq tx-sender company) (err ERR_NOT_AUTHORIZED))
        (asserts! (is-eq (get status project) "active") (err ERR_PROJECT_NOT_ACTIVE))
        (asserts! (is-eq (get verifications-received project) u0) (err ERR_INVALID_VERIFICATION))
        (try! (as-contract (stx-transfer? deposit-amount tx-sender company)))
        (map-set projects
            {project-id: project-id}
            (merge project {status: "cancelled"})
        )
        (var-set total-deposits (- (var-get total-deposits) deposit-amount))
        (ok deposit-amount)
    )
)

(define-public (emergency-release (project-id uint))
    (let 
        (
            (project (unwrap! (map-get? projects {project-id: project-id}) (err ERR_PROJECT_NOT_FOUND)))
            (company (get company project))
            (deposit-amount (get deposit-amount project))
        )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
        (asserts! (not (is-eq (get status project) "released")) (err ERR_FUNDS_ALREADY_RELEASED))
        
        (try! (as-contract (stx-transfer? deposit-amount tx-sender company)))
        
        (map-set projects 
            {project-id: project-id}
            (merge project {status: "emergency-released", released-at: (some stacks-block-height)})
        )
        
        (var-set total-released (+ (var-get total-released) deposit-amount))
        
        (ok deposit-amount)
    )
)

(define-read-only (get-project (project-id uint))
    (map-get? projects {project-id: project-id})
)

(define-read-only (get-project-verification (project-id uint) (verifier principal))
    (map-get? project-verifications {project-id: project-id, verifier: verifier})
)

(define-read-only (is-verifier (address principal))
    (default-to false (map-get? verifiers address))
)

(define-read-only (get-contract-stats)
    {
        total-projects: (- (var-get next-project-id) u1),
        total-deposits: (var-get total-deposits),
        total-released: (var-get total-released),
        funds-in-escrow: (- (var-get total-deposits) (var-get total-released))
    }
)

(define-read-only (get-contract-balance)
    (stx-get-balance (as-contract tx-sender))
)

(define-read-only (get-next-project-id)
    (var-get next-project-id)
)

(define-public (add-milestone (project-id uint) (description (string-ascii 256)))
    (let
        (
            (project (unwrap! (map-get? projects {project-id: project-id}) (err ERR_PROJECT_NOT_FOUND)))
            (company (get company project))
            (current-milestones (get milestones-count project))
            (new-milestone-id (+ current-milestones u1))
        )
        (asserts! (is-eq tx-sender company) (err ERR_NOT_AUTHORIZED))
        (asserts! (is-eq (get status project) "active") (err ERR_PROJECT_NOT_ACTIVE))
        (map-set project-milestones
            {project-id: project-id, milestone-id: new-milestone-id}
            {
                description: description,
                completed: false,
                completed-at: none
            }
        )
        (map-set projects
            {project-id: project-id}
            (merge project {milestones-count: new-milestone-id})
        )
        (ok new-milestone-id)
    )
)

(define-public (complete-milestone (project-id uint) (milestone-id uint))
    (let
        (
            (project (unwrap! (map-get? projects {project-id: project-id}) (err ERR_PROJECT_NOT_FOUND)))
            (company (get company project))
            (milestone (unwrap! (map-get? project-milestones {project-id: project-id, milestone-id: milestone-id}) (err ERR_INVALID_VERIFICATION)))
        )
        (asserts! (is-eq tx-sender company) (err ERR_NOT_AUTHORIZED))
        (asserts! (is-eq (get status project) "active") (err ERR_PROJECT_NOT_ACTIVE))
        (asserts! (not (get completed milestone)) (err ERR_INVALID_VERIFICATION))
        (map-set project-milestones
            {project-id: project-id, milestone-id: milestone-id}
            (merge milestone {completed: true, completed-at: (some stacks-block-height)})
        )
        (ok milestone-id)
    )
)

(define-read-only (get-milestone (project-id uint) (milestone-id uint))
    (map-get? project-milestones {project-id: project-id, milestone-id: milestone-id})
)

(define-read-only (get-project-milestones (project-id uint))
    (let
        (
            (project (unwrap! (map-get? projects {project-id: project-id}) (err ERR_PROJECT_NOT_FOUND)))
            (milestones-count (get milestones-count project))
        )
        (ok milestones-count)
    )
)

(define-public (transfer-project-ownership (project-id uint) (new-owner principal))
    (let
        (
            (project (unwrap! (map-get? projects {project-id: project-id}) (err ERR_PROJECT_NOT_FOUND)))
            (current-owner (get company project))
        )
        (asserts! (is-eq tx-sender current-owner) (err ERR_NOT_AUTHORIZED))
        (asserts! (not (is-eq new-owner current-owner)) (err ERR_INVALID_VERIFICATION))
        (asserts! (is-eq (get status project) "active") (err ERR_PROJECT_NOT_ACTIVE))
        (ok (map-set projects {project-id: project-id} (merge project {company: new-owner})))
    )
)
