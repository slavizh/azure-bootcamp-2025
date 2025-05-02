param ruleCollections array
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-05-01' existing = {
  name: 'myFirewallPolicy'
}

resource ruleCollectionGroups 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = {
  name: 'myRuleCollectionGroup'
  parent: firewallPolicy
  properties: {
    priority: 101
    ruleCollections: [for ruleCollection in ruleCollections: {
      ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
      name: ruleCollection
      action: {
        type: ruleCollection.action
      }
      priority: ruleCollection.priority
      rules: map(ruleCollection.rules, rule => {
        ruleType: rule.ruleType
        name: rule.name
        description: rule.description
      })
    }]
  }
}
