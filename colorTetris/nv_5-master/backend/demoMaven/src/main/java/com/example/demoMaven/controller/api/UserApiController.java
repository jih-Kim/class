package com.example.demoMaven.controller.api;

import com.example.demoMaven.model.entity.User;
import com.example.demoMaven.service.UserApiLogicService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.awt.print.PrinterException;

/**
 * Controller for user
 * @author Jihoo
 * @author Dongwoo
 */

@Slf4j
@RestController
@RequestMapping("/api/user")
public class UserApiController {

    /**
     * UserApiLogicService
     */
    @Autowired
    private UserApiLogicService userApiLogicService;

    /**
     * test method for user
     * @return String
     */
    @RequestMapping(method = RequestMethod.GET, path = "/test")
    private String test() {
        return "The user page is working now";
    }

    /**
     * create method for user
     * @param user
     */
    @PostMapping("/create")
    private void create(@RequestBody User user) {
        userApiLogicService.create(user);
        System.out.println("Succeed");
    }

    /**
     * update method for user
     * @param user
     * @param account
     * @throws PrinterException
     */
    @PutMapping("/updatePw/{account}")
    private void update(@RequestBody User user, @PathVariable String account) throws PrinterException {
        userApiLogicService.updatePw(user, account);
    }

    /**
     * delete method for user
     * @param id
     */
    @DeleteMapping("/delete/{id}")
    private void delete(@PathVariable Long id) {
        userApiLogicService.delete(id);
    }

    /**
     * check if account is duplicate
     * return 0 if account is duplicate or else return 1
     * @param user
     * @return boolean
     */
    @PostMapping("/checkSignUp")
    private boolean checkAccountDuplicate(@RequestBody User user)
    {
        return userApiLogicService.checkAccountDuplicate(user.getAccount());
    }

    /**
     * check password match account
     * return 0 if password is not match to account or else return 1
     * @param user
     * @return boolean
     */
    @PostMapping("/checkPassword")
    private boolean checkPasswordMatchAccount(@RequestBody User user)
    {
        return userApiLogicService.checkPasswordMatchAccount(user.getAccount(),user.getPw());
    }

}
