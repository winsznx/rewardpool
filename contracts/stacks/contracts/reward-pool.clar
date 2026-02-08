;; RewardPool - Staking rewards
(define-constant ERR-NO-STAKE (err u100))
(define-constant ERR-TOO-EARLY (err u101))

(define-map stakes
    { user: principal }
    { amount: uint, timestamp: uint, last-claim: uint }
)

(define-data-var reward-rate uint u100)

(define-public (stake (amount uint))
    (let ((current-stake (default-to { amount: u0, timestamp: block-height, last-claim: block-height } (map-get? stakes { user: tx-sender }))))
        (map-set stakes { user: tx-sender } { 
            amount: (+ (get amount current-stake) amount),
            timestamp: block-height,
            last-claim: (get last-claim current-stake)
        })
        (ok true)
    )
)

(define-public (claim)
    (let ((stake-info (unwrap! (map-get? stakes { user: tx-sender }) ERR-NO-STAKE)))
        (asserts! (> (get amount stake-info) u0) ERR-NO-STAKE)
        (map-set stakes { user: tx-sender } (merge stake-info { last-claim: block-height }))
        (ok true)
    )
)

(define-read-only (get-stake (user principal))
    (map-get? stakes { user: user })
)
