

package com.ms.semicolans.sereportapi.sereportapi.jwt;

public class UsernameAndPasswordAuthenticationRequest {
    private String username;
    private String password;
    private String pinnumber;

    public UsernameAndPasswordAuthenticationRequest() {

    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPinnumber() {
        return pinnumber;
    }

    public void setPinnumber(String pinnumber) {
        this.pinnumber = pinnumber;
    }
}
