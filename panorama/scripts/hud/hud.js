'use strict'

class FallDamageHUD
{
	static panels = {
		healthsPanel: $('#HudHealthValuesPanel'),
		healthChargeText: $('#HudHealthCharge'),
	};

	static currentHealth = 'null';
	static currentMaxHealth = 'null';
	static hudSize = 'null';

	static
	{
		$.RegisterForUnhandledEvent('Drawer_NavigateToTab', this.OnHudHealthValueChanged.bind(this));	// HEALTH

		$.RegisterForUnhandledEvent('Drawer_ExtendAndNavigateToTab', this.OnHudHealthMaxValueChanged.bind(this));	// HEALTH MAX

		$.RegisterForUnhandledEvent('Drawer_UpdateLobbyButton', this.OnHudSizeValueChanged.bind(this));	// HUD SIZE
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

	static OnHudSizeValueChanged(value)
	{
		this.hudSize = value;
		$.Msg(`HUD size updated: ${this.hudSize}`);
		this.UpdateHealthSize();
	}

	static UpdateHealthText()
	{
		this.panels.healthChargeText.text = `HEALTH: ${this.currentHealth} / ${this.currentMaxHealth}`;
	}

	static UpdateHealthSize()
	{
		this.ResetSizing()
		this.panels.healthChargeText.AddClass(`Size${this.hudSize}`);
	}
	static ResetSizing()
	{
		this.panels.healthChargeText.RemoveClass(`Size1`);
		this.panels.healthChargeText.RemoveClass(`Size2`);
		this.panels.healthChargeText.RemoveClass(`Size3`);
		this.panels.healthChargeText.RemoveClass(`Size4`);
	}
}
