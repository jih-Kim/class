package com.example.demo;

public class User {

	private final long id;
	private final String password;
	
	public User (long id, String password) {
		this.id = id;
		this.password =password;
	}
	public long getId() {
		return id;
	}
	public String getPassword() {
		return password;
	}
}
