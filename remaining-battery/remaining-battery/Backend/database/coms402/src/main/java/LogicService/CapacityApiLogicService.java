package LogicService;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;

import Entity.Capacity;
import Repository.CapacityRepository;

public class CapacityApiLogicService {

    @Autowired
    private CapacityRepository capacityRepository;

    public Capacity create(Capacity cap){
       Capacity mainCap = new Capacity();
       mainCap.setCapacity(cap.getCapacity());
       mainCap.setCap_id(cap.getCap_id());

       capacityRepository.save(mainCap);
       return mainCap;
    }

    public List<Capacity> read(){
        return capacityRepository.findAll();
    }

    public void delete(Long id){
        capacityRepository.deleteById(id);;
    }


}
