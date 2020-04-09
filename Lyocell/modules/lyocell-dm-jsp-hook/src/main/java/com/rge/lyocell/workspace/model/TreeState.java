package com.rge.lyocell.workspace.model;

public class TreeState {

	@Override
	public String toString() {
		return "TreeState [opened=" + opened + ", selected=" + selected + "]";
	}

	private Boolean opened;
	private Boolean selected;

	public TreeState(Boolean opened, Boolean selected) {
		super();
		this.opened = opened;
		this.selected = selected;
	}

	public Boolean getOpened() {
		return opened;
	}

	public void setOpened(Boolean opened) {
		this.opened = opened;
	}

	public Boolean getSelected() {
		return selected;
	}

	public void setSelected(Boolean selected) {
		this.selected = selected;
	}

}
