
package com.example.demoMaven.controller.api.FriendController;

import com.example.demoMaven.model.entity.FriendEnity.Friendlist;
import com.example.demoMaven.service.FriendService.FriendListApiLogicService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

/**
 * Controller for FriendList
 * @author Jihoo
 */

@Slf4j
@RestController
@RequestMapping("/api/friend")
public class FriendListApiController
{
    /**
     * Friendlistlogicservice
     */
    @Autowired
    private FriendListApiLogicService FriendListApiLogicService;

    /**
     * create method for friendlist
     * @param request
     * @param account
     */
    @PostMapping("/{account}/create")
    public void create(@RequestBody Friendlist request, @PathVariable String account)
    {
        FriendListApiLogicService.create(request,account);
    }

    /**
     * read method for friendlist
     * @param account
     * @return ArrayList<String>
     */
    @GetMapping("/{account}/read")
    public ArrayList<String> read(@PathVariable String account)
    {
        return FriendListApiLogicService.read(account);
    }

    /**
     * delete method for friendlist
     * @param account
     * @param friendname
     */
    @DeleteMapping("/{account}/delete/{friendname}")
    public void delete(@PathVariable String account,@PathVariable String friendname)
    {
        FriendListApiLogicService.delete(account, friendname);
    }
}

