Check the behaviors when

| Situation                                                    | Solar Router | EV plugged(% SoC) | Production | Grid Exchange (<0 : export) | Action on Solar Router |
| ------------------------------------------------------------ | ------------ | ----------------- | ---------- | --------------------------- | ---------------------- |
| EV is not plugged and export                                 | OFF          | not plugged       | 600w       | -100W                       | Turn ON                |
| EV is plugged but sun is too small                           | ON           | plugged (40%)     | 600w       | -10W                        | Unchanged              |
| EV is plugged and sun reach the charger start level          | ON           | plugged (40%)     | 1400w      | -10W                        | Turn OFF               |
| EV is plugged and EV is charging                             | OFF          | plugged (50%)     | 3400w      | -10W                        | Unchanged              |
| EV is charging but a cloud is hiding the solar pannels       | OFF          | plugged (60%)     | 600w       | -400W                       | Turn ON                |
| EV is plugged and could go away                              | ON           | plugged (60%)     | 3400w      | -1200W                      | Turn OFF               |
| EV is plugged and charge reach 100% but charge is continuing | OFF          | plugged (100%)    | 3400w      | -10W                        | Unchanged              |
| EV is plugged and charge is completed                        | OFF          | plugged (100%)    | 3400w      | -1200W                      | Turn ON                |
| EV is fully charged                                          | ON           | plugged (100%)    | 3400w      | -200W                       | Unchanged              |
| EV is unplugged                                              | OFF          | not plugged       | N.A.       | N.A.                        | Turn ON                |
| EV is unplugged                                              | ON           | not plugged       | N.A.       | N.A.                        | Unchanged              |
