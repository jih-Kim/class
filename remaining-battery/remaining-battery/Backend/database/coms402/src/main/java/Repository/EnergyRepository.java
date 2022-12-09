package Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import Entity.Energy;

public interface EnergyRepository extends JpaRepository<Energy,Long> {

}
