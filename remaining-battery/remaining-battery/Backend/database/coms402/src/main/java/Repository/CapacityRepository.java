package Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import Entity.Capacity;

public interface CapacityRepository extends JpaRepository<Capacity, Long> {
    
}
