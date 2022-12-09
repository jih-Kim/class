package LogicService;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;

import Entity.Table;
import Repository.TableRepository;

/*
@author jihoo
*/
public class TableApiLogicService {

    @Autowired
    private TableRepository tableRepository;

    public Table create(Table table){
       Table mainTable = new Table();
       mainTable.setCapacity(table.getCapacity());
       mainTable.setCellName(table.getCellName());
       mainTable.setChannel_id(table.getChannel_id());
       mainTable.setCurrent(table.getCurrent());
       mainTable.setCycle(table.getCycle());
       mainTable.setCycleLife(table.getCycleLife());
       mainTable.setEnergyChange(table.getEnergyChange());
       mainTable.setStatus(table.getStatus());
       mainTable.setVoltage(table.getVoltage());
       tableRepository.save(mainTable);
       return mainTable;
    }

    public List<Table> read(){
        return tableRepository.findAll();
    }

    public void delete(Long id){
        tableRepository.deleteById(id);;
    }


}
