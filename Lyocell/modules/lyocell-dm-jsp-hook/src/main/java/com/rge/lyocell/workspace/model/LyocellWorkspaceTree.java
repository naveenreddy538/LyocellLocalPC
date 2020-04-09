package com.rge.lyocell.workspace.model;

import java.util.ArrayList;
import java.util.List;

// Model to generate tree structure
public class LyocellWorkspaceTree {

	private String text;
	private Long id;
	private Long parentId;
	private Boolean leaf;
	private String type;
	private Boolean expanded;
	private Boolean cache;
	private Boolean node;
	private LyocellWorkspaceTree parent = null;
	private TreeState state = new TreeState(true, false);
	private List<LyocellWorkspaceTree> children = new ArrayList<LyocellWorkspaceTree>();

	public LyocellWorkspaceTree(String text, Long id, Boolean leaf, String type, Boolean expanded, Boolean cache,
			Long parentId) {
		super();
		this.text = text;
		this.id = id;
		this.leaf = leaf;
		this.type = type;
		this.expanded = expanded;
		this.cache = cache;
		this.parentId = parentId;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public Boolean getLeaf() {
		return leaf;
	}

	public void setLeaf(Boolean leaf) {
		this.leaf = leaf;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public Boolean getExpanded() {
		return expanded;
	}

	public void setExpanded(Boolean expanded) {
		this.expanded = expanded;
	}

	public Boolean getCache() {
		return cache;
	}

	public void setCache(Boolean cache) {
		this.cache = cache;
	}

	public Boolean getNode() {
		return node;
	}

	public void setNode(Boolean node) {
		this.node = node;
	}

	public void setParent(LyocellWorkspaceTree parent) {
		this.parent = parent;
	}

	public LyocellWorkspaceTree getParent() {
		return parent;
	}

	public TreeState getState() {
		return state;
	}

	public void setState(TreeState state) {
		this.state = state;
	}

	public List<LyocellWorkspaceTree> getChildren() {
		return children;
	}

	public LyocellWorkspaceTree addChild(LyocellWorkspaceTree child) {
		// child.setParent(this);
		this.children.add(child);
		return child;
	}

	public void addChildren(List<LyocellWorkspaceTree> children) {
		children.forEach(each -> each.setParent(this));
		this.children.addAll(children);
	}

	@Override
	public String toString() {
		return "LyocellWorkspaceTree [text=" + text + ", id=" + id + ", parentId=" + parentId + ", leaf=" + leaf
				+ ", type=" + type + ", expanded=" + expanded + ", cache=" + cache + ", node=" + node + ", parent="
				+ parent + ", state=" + state + ", children=" + children + "]";
	}

}