package Controller;

import java.util.List;
import Entity.Table;
import LogicService.TableApiLogicService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/table")
public class TableController {
    @Autowired
    private TableApiLogicService tableApiLogicService;
    
    @RequestMapping(method = RequestMethod.GET, path = "/test")
    private String test(){
        return "The table page is working now";
    }

    @PostMapping("/create")
    private void create(@RequestBody Table table){
        tableApiLogicService.create(table);
        System.out.print("Succeed");
    }

    @GetMapping("/readAll")
    private List<Table> readAll(){
        return tableApiLogicService.read();
    }

    //DO we need update for table?

    @DeleteMapping("/delete/{id}")
    private void delete(@PathVariable Long id){
        tableApiLogicService.delete(id);
    }
        
}
