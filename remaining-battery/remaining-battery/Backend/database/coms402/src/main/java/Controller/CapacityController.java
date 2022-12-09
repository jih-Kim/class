package Controller;

import Entity.Capacity;
import LogicService.CapacityApiLogicService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/table/{id}")
public class CapacityController {
    @Autowired
    private CapacityApiLogicService capacityApiLogicService;
    
    @RequestMapping(method = RequestMethod.GET, path = "/test")
    private String test(){
        return "The table page is working now";
    }

    @PostMapping("/create")
    private void create(@RequestBody Capacity capacity){
        capacityApiLogicService.create(capacity);
        System.out.print("Succeed");
    }

    @GetMapping("/readAll")
    private List<Capacity> readAll(){
        return capacityApiLogicService.read();
    }

    //DO we need update for table?

    @DeleteMapping("/delete/{id}")
    private void delete(@PathVariable Long id){
        capacityApiLogicService.delete(id);
    }
        
}
