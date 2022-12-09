package Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import Entity.Cycle;


public interface CycleRepository extends JpaRepository<Cycle, Long> {
    
}
