;; RewardPool - Staking rewards
(define-constant ERR-NO-STAKE (err u100))
(define-constant ERR-TOO-EARLY (err u101))
(define-event staked 
  (user principal) 
  (amount uint) 
  (total-staked uint) 
  (timestamp uint)
)

(define-event reward-claimed 
  (user principal) 
  (amount uint) 
  (rewards uint) 
  (timestamp uint)
)

(define-event unstaked 
  (user principal) 
  (amount uint) 
  (remaining-stake uint) 
  (timestamp uint)
)

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
         (emit-event (staked tx-sender amount new-total block-height))
        (ok true)
    )
)

(define-public (claim)
    (let ((stake-info (unwrap! (map-get? stakes { user: tx-sender }) ERR-NO-STAKE)))
        (asserts! (> (get amount stake-info) u0) ERR-NO-STAKE)
        (map-set stakes { user: tx-sender } (merge stake-info { last-claim: block-height }))
        (emit-event (reward-claimed tx-sender stake-amount rewards-amount block-height))
        (ok true)
    )
)

;; Added an unstake function with event
(define-public (unstake (amount uint))
    (let ((stake-info (unwrap! (map-get? stakes { user: tx-sender }) ERR-NO-STAKE))
          (current-amount (get amount stake-info)))
        
        (asserts! (>= current-amount amount) ERR-NO-STAKE)
        (let ((remaining (- current-amount amount)))
            (map-set stakes { user: tx-sender } (merge stake-info { 
                amount: remaining,
                timestamp: block-height
            }))
            
            ;; EMIT EVENT HERE
            (emit-event (unstaked tx-sender amount remaining block-height))
            
            (ok amount)
        )
    )
)

(define-event reward-rate-updated (old-rate uint) (new-rate uint) (updated-by principal) (timestamp uint))

;; Added admin function to update reward rate
(define-public (set-reward-rate (new-rate uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) ERR-UNAUTHORIZED)
        (let ((old-rate (var-get reward-rate)))
            (var-set reward-rate new-rate)
            (emit-event (reward-rate-updated old-rate new-rate tx-sender block-height))
            (ok true)
        )
    )
)


(define-read-only (get-stake (user principal))
    (map-get? stakes { user: user })
)
