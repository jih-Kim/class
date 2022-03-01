//package com.syntech.spurno.colortetris;
//
//
//
//import com.google.gson.JsonObject;
//
//import org.json.JSONException;
//import org.json.JSONObject;
//import org.junit.Assert;
//import org.junit.Before;
//import org.junit.Rule;
//import org.junit.Test;
//import org.mockito.junit.MockitoJUnit;
//import org.mockito.junit.MockitoRule;
//import static org.mockito.Mockito.mock;
//import static org.mockito.Mockito.when;
//
//
//
//
//public class GETResponseTest {
//
//    @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();
//
//
//    @Test
//    public void getResponseTest_returnsTrue() throws JSONException {
//        login test = mock(login.class);
//
//        singleplayer testsingleplayer = new singleplayer();
//
//        String username = "Michael";
//        String passwordCorrect = "Scott";
//
//        Boolean response= true;
//        when(test.getSignedin()).thenReturn(response);
//        when(test.getUsername()).thenReturn(username);
//        JSONObject score = new JSONObject();
//        score.put("account", "Michael");
//        score.put("score", 5000);
//
//
//
//
//
//        Assert.assertEquals(testsingleplayer.getPersonal_high(),5000);
//    }
//
//
//}
