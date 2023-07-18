/*  Covid 19 Data From 2020-2023 | SQL Data Exploration  */

/*  Select data from CovidDeaths table that we are going to be using 
	and ordering it by the first two columns. Taking a look at the data
	helps us figure out what insights to looks for.                       */

Select
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
From 
	CovidDeaths
Order By
	Location, 
	date,


---


/*  Looking at Total Cases vs Total Deaths  */

/*  The CAST() function is used to convert from nvarchar to a decimal data 
	type in order to divide the columns. The WHERE clause & LIKE operator 
	are used to show the location that has 'states' in it which will only 
	show United States. The 'continent IS NOT NULL' is used to not
    show any of the null values in continent. Finally, I ordered  it by 
	acending based of the first two columns.                                  */

Select 
	Location, 
	date, 
	total_cases, 
	total_deaths,
	(cast(total_deaths as decimal)/cast(total_cases as decimal))*100 as DeathPercentage
From 
	CovidDeaths
Where 
	location like '%states%' and continent is not null
Order By 
	Location, 
	date,


---


/*  Looking at Total Cases vs Population */

/*  Shows what percentage of population got Covid  */

Select 
	Location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 as PercentPopulationInfected
From 
	CovidDeaths
Order By 
	Location, 
	date,


---


/*  Looking at Countries with Highest Infection Rate vs Population */

/*  Since the aggergete function 'Max() was used, we are required to use the 'Order By' */

Select 
	Location, 
	population, 
	Max(total_cases) as HighestInfectionCount, 
	((Max(total_cases)/population))*100 as PercentPopulationInfected
From 
	CovidDeaths
Group By 
	Location, 
	population
Order By 
	PercentPopulationInfected desc


---


/*  Looking at Countries with Highest Death Count */

Select 
	Location, 
	Max(cast(total_deaths as bigint)) as TotalDeathCount
From 
	CovidDeaths
Where 
	continent is not null
Group By 
	Location
Order By 
	TotalDeathCount desc


---


/*  Looking at Continents with Highest Death Count */

Select 
	continent, 
	Max(cast(total_deaths as int)) as TotalDeathCount
From 
	CovidDeaths
Where 
	continent is not null
Group By 
	continent
Order By 
	TotalDeathCount desc


---


/*	Global Numbers  */

/*	This shows the overall data in this set.  */

Select 
	Sum(new_cases) as Total_Cases, 
	Sum(cast(new_deaths as int)) as Total_Deaths,
	(Sum(cast(new_deaths as int))/nullif(Sum(new_cases),0))*100 as DeathPercentage
From 
	CovidDeaths
Where 
	continent is not null
Order By 
	1,2


---


/*  Looking at Total Population vs Vaccinations */


/*  Here I am bringing in another table by using the 'Join' fuction.
	The default join operation is inner join which will only bring in the
	data that has the same location and date. The partition by clause is used
	to account for the rolling count fo the people vaccinated.                */
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations as bigint)) 
		Over (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From 
	CovidDeaths dea
Join 
	CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
Where 
	dea.continent is not null
Order By 
	2,3


---


/*  Common Table Expression (CTE) */

/*  We are using the same query as the previous on and looking at
	Total Population vs Vaccinations, but now using a CTE          */

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
	Select 
		dea.continent, 
		dea.location, 
		dea.date, dea.population, 
		vac.new_vaccinations, 
		Sum(cast(vac.new_vaccinations as bigint)) 
			Over (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
	From 
		CovidDeaths dea
	Join CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where 
		dea.continent is not null
)
Select 
	*, 
	(RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
From 
	PopvsVac
Order By 
		2,3

---


/*  Temp Table */

/*  We are using the same query as the previous on and looking at
	Total Population vs Vaccinations, but now using a Temp Table         */

Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccination numeric,
	RollingPeopleVaccinated numeric,
	)

Insert into #PercentPopulationVaccinated
	Select 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		Sum(cast(vac.new_vaccinations as bigint)) 
			Over (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
	From 
		CovidDeaths dea
	Join PortfolioProject2..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date

Select 
	*, 
	(RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
From 
	#PercentPopulationVaccinated