'use strict'

class FallDamageHUD
{
	static panels = {
		healthsPanel: $('#HudHealthValuesPanel'),
		healthChargeText: $('#HudHealthCharge'),
	};

	static currentHealth = 'null';
	static currentMaxHealth = 'null';

	static
	{
		$.RegisterForUnhandledEvent('Drawer_NavigateToTab', this.OnHudHealthValueChanged.bind(this));	// HEALTH

		$.RegisterForUnhandledEvent('Drawer_ExtendAndNavigateToTab', this.OnHudHealthMaxValueChanged.bind(this));	// HEALTH MAX
	}

	static OnHudHealthValueChanged(value)
	{
		this.currentHealth = value;
		$.Msg(`Health updated: ${this.currentHealth}`);
		this.UpdateHealthText();
	}

	static OnHudHealthMaxValueChanged(value)
	{
		this.currentMaxHealth = value;
		$.Msg(`MAX Health updated: ${this.currentMaxHealth}`);
		this.UpdateHealthText();
	}

	static UpdateHealthText()
	{
		this.panels.healthChargeText.text = `HEALTH: ${this.currentHealth} / ${this.currentMaxHealth}`;
	}
}
